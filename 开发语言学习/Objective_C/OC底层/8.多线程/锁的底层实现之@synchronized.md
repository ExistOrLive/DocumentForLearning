# 锁的底层实现之@synchronized

`@synchronized` 是最简单最方便的互斥锁，同时也是性能最差的互斥锁。`@synchronized`以token作为锁的唯一标志，因此token在`@synchronized`使用阶段是不可以修改的，因此最好选择常量或者在使用阶段确定不会修改的变量。

```objc 
@synchronized (token) {
     // critical code 临界区
}
```

## 1. @synchronized 的实现

```objc
dispatch_queue_t queue = dispatch_queue_create("serialNumber", DISPATCH_QUEUE_CONCURRENT);
        
static int sharedValue = 0;
        
for(int i = 0; i < 10 ; i ++) {
    dispatch_async(queue, ^{
        @synchronized (queue) {
            sharedValue = i;
        }
    });
}
```

我们通过断点调试，并查看断点处的汇编代码：

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-07-08%20%E4%B8%8B%E5%8D%887.47.21.png)

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-07-08%20%E4%B8%8B%E5%8D%887.47.15.png)

`@synchronized`代码块其实就是`objc_sync_enter`和`objc_sync_exit`两个函数包围起来的。进一步调试发现两个函数的实现是**libobjc**中。

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-07-08%20%E4%B8%8B%E5%8D%887.49.33.png)


### 1.1 `objc_sync_enter` `objc_sync_exit`

`objc_sync_enter` 请求锁， `objc_sync_exit` 释放锁。

当 token 为 空，什么都不做，不会请求和释放锁。

```objc

// objc4-818.2 

int objc_sync_enter(id obj)
{
    int result = OBJC_SYNC_SUCCESS;

    if (obj) {
        SyncData* data = id2data(obj, ACQUIRE);
        ASSERT(data);
        data->mutex.lock();
    } else {
        // @synchronized(nil) does nothing
        if (DebugNilSync) {
            _objc_inform("NIL SYNC DEBUG: @synchronized(nil); set a breakpoint on objc_sync_nil to debug");
        }
        objc_sync_nil();
    }

    return result;
}


int objc_sync_exit(id obj)
{
    int result = OBJC_SYNC_SUCCESS;
    
    if (obj) {
        SyncData* data = id2data(obj, RELEASE); 
        if (!data) {
            result = OBJC_SYNC_NOT_OWNING_THREAD_ERROR;
        } else {
            bool okay = data->mutex.tryUnlock();
            if (!okay) {
                result = OBJC_SYNC_NOT_OWNING_THREAD_ERROR;
            }
        }
    } else {
        // @synchronized(nil) does nothing
    }
	

    return result;
}

```

## 2. `SyncData`

`SyncData` 是一个保存@synchronized同步相关数据的结构.

- `object`: 同步锁的token
- `mutex`: 递归锁
- `nextData`: `SyncData`是以链表的结构保存在内存中
- `threadCount`: 当前有多少线程请求了该锁

```objc

typedef struct alignas(CacheLineSize) SyncData {
    struct SyncData* nextData;
    DisguisedPtr<objc_object> object;
    int32_t threadCount;  // number of THREADS using this block
    recursive_mutex_t mutex;
} SyncData;

```

`SyncData` 通过三层缓存结构保存在内存中：

- 以`SYNC_DATA_DIRECT_KEY`为key，保存在线程的本地变量中

```objc
SyncData *data = (SyncData *)tls_get_direct(SYNC_DATA_DIRECT_KEY);

void *pthread_getspecific(unsigned long);
int pthread_setspecific(unsigned long, const void *);
```

- 保存在`SyncCache`中, `SyncCache`以`_objc_pthread_key`保存在线程的本地变量中

```objc
typedef struct {
    SyncData *data;
    unsigned int lockCount;  // number of times THIS THREAD locked this block
} SyncCacheItem;

typedef struct SyncCache {
    unsigned int allocated;
    unsigned int used;
    SyncCacheItem list[0];
} SyncCache;

SyncCache *cache = fetch_cache(NO);
```

- `SyncData`以链表的形式保存在全局变量`sDataLists`中，`sDataLists`是一个数组，保存了8(ios8个/macos64)个链表头指针以及8个自旋锁；8个链表将保存全局所有的`SyncData`, 自旋锁用于保证

```objc
struct SyncList {
    SyncData *data;
    spinlock_t lock;

    constexpr SyncList() : data(nil), lock(fork_unsafe_lock) { }
};
// 获取锁
#define LOCK_FOR_OBJ(obj) sDataLists[obj].lock
// 获取链表
#define LIST_FOR_OBJ(obj) sDataLists[obj].data
static StripedMap<SyncList> sDataLists;

class StripedMap {
#if TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR
    enum { StripeCount = 8 };
#else
    enum { StripeCount = 64 };
#endif

    struct PaddedT {
        T value alignas(CacheLineSize);
    };
    
    // 数组 
    PaddedT array[StripeCount];

     // hash函数
    static unsigned int indexForPointer(const void *p) {
        uintptr_t addr = reinterpret_cast<uintptr_t>(p);
        return ((addr >> 4) ^ (addr >> 9)) % StripeCount;
    }    
}
```


## 3. `id2data`

```objc
static SyncData* id2data(id object, enum usage why)
{
    spinlock_t *lockp = &LOCK_FOR_OBJ(object);
    SyncData **listp = &LIST_FOR_OBJ(object);
    SyncData* result = NULL;

#if SUPPORT_DIRECT_THREAD_KEYS
    // Check per-thread single-entry fast cache for matching object
    bool fastCacheOccupied = NO;
    SyncData *data = (SyncData *)tls_get_direct(SYNC_DATA_DIRECT_KEY);
    if (data) {
        fastCacheOccupied = YES;

        if (data->object == object) {
            // Found a match in fast cache.
            uintptr_t lockCount;

            result = data;
            lockCount = (uintptr_t)tls_get_direct(SYNC_COUNT_DIRECT_KEY);
            if (result->threadCount <= 0  ||  lockCount <= 0) {
                _objc_fatal("id2data fastcache is buggy");
            }

            switch(why) {
            case ACQUIRE: {
                lockCount++;
                tls_set_direct(SYNC_COUNT_DIRECT_KEY, (void*)lockCount);
                break;
            }
            case RELEASE:
                lockCount--;
                tls_set_direct(SYNC_COUNT_DIRECT_KEY, (void*)lockCount);
                if (lockCount == 0) {
                    // remove from fast cache
                    tls_set_direct(SYNC_DATA_DIRECT_KEY, NULL);
                    // atomic because may collide with concurrent ACQUIRE
                    OSAtomicDecrement32Barrier(&result->threadCount);
                }
                break;
            case CHECK:
                // do nothing
                break;
            }

            return result;
        }
    }
#endif

    // Check per-thread cache of already-owned locks for matching object
    SyncCache *cache = fetch_cache(NO);
    if (cache) {
        unsigned int i;
        for (i = 0; i < cache->used; i++) {
            SyncCacheItem *item = &cache->list[i];
            if (item->data->object != object) continue;

            // Found a match.
            result = item->data;
            if (result->threadCount <= 0  ||  item->lockCount <= 0) {
                _objc_fatal("id2data cache is buggy");
            }
                
            switch(why) {
            case ACQUIRE:
                item->lockCount++;
                break;
            case RELEASE:
                item->lockCount--;
                if (item->lockCount == 0) {
                    // remove from per-thread cache
                    cache->list[i] = cache->list[--cache->used];
                    // atomic because may collide with concurrent ACQUIRE
                    OSAtomicDecrement32Barrier(&result->threadCount);
                }
                break;
            case CHECK:
                // do nothing
                break;
            }

            return result;
        }
    }

    // Thread cache didn't find anything.
    // Walk in-use list looking for matching object
    // Spinlock prevents multiple threads from creating multiple 
    // locks for the same new object.
    // We could keep the nodes in some hash table if we find that there are
    // more than 20 or so distinct locks active, but we don't do that now.
    
    lockp->lock();

    {
        SyncData* p;
        SyncData* firstUnused = NULL;
        for (p = *listp; p != NULL; p = p->nextData) {
            if ( p->object == object ) {
                result = p;
                // atomic because may collide with concurrent RELEASE
                OSAtomicIncrement32Barrier(&result->threadCount);
                goto done;
            }
            if ( (firstUnused == NULL) && (p->threadCount == 0) )
                firstUnused = p;
        }
    
        // no SyncData currently associated with object
        if ( (why == RELEASE) || (why == CHECK) )
            goto done;
    
        // an unused one was found, use it
        if ( firstUnused != NULL ) {
            result = firstUnused;
            result->object = (objc_object *)object;
            result->threadCount = 1;
            goto done;
        }
    }

    // Allocate a new SyncData and add to list.
    // XXX allocating memory with a global lock held is bad practice,
    // might be worth releasing the lock, allocating, and searching again.
    // But since we never free these guys we won't be stuck in allocation very often.
    posix_memalign((void **)&result, alignof(SyncData), sizeof(SyncData));
    result->object = (objc_object *)object;
    result->threadCount = 1;
    new (&result->mutex) recursive_mutex_t(fork_unsafe_lock);
    result->nextData = *listp;
    *listp = result;
    
 done:
    lockp->unlock();
    if (result) {
        // Only new ACQUIRE should get here.
        // All RELEASE and CHECK and recursive ACQUIRE are 
        // handled by the per-thread caches above.
        if (why == RELEASE) {
            // Probably some thread is incorrectly exiting 
            // while the object is held by another thread.
            return nil;
        }
        if (why != ACQUIRE) _objc_fatal("id2data is buggy");
        if (result->object != object) _objc_fatal("id2data is buggy");

#if SUPPORT_DIRECT_THREAD_KEYS
        if (!fastCacheOccupied) {
            // Save in fast thread cache
            tls_set_direct(SYNC_DATA_DIRECT_KEY, result);
            tls_set_direct(SYNC_COUNT_DIRECT_KEY, (void*)1);
        } else 
#endif
        {
            // Save in thread cache
            if (!cache) cache = fetch_cache(YES);
            cache->list[cache->used].data = result;
            cache->list[cache->used].lockCount = 1;
            cache->used++;
        }
    }

    return result;
}

```

### 3.1 获取SyncData

- 首先从线程的本地缓冲中直接获取

```objc
SyncData *data = (SyncData *)tls_get_direct(SYNC_DATA_DIRECT_KEY);
```

- 接着试图从线程的本地缓存中间接获取

```objc
SyncCache *cache = fetch_cache(NO);

static SyncCache *fetch_cache(bool create)
{
    _objc_pthread_data *data;
    
    data = _objc_fetch_pthread_data(create);
    if (!data) return NULL;

    if (!data->syncCache) {
        if (!create) {
            return NULL;
        } else {
            int count = 4;
            data->syncCache = (SyncCache *)
                calloc(1, sizeof(SyncCache) + count*sizeof(SyncCacheItem));
            data->syncCache->allocated = count;
        }
    }

    // Make sure there's at least one open slot in the list.
    if (data->syncCache->allocated == data->syncCache->used) {
        data->syncCache->allocated *= 2;
        data->syncCache = (SyncCache *)
            realloc(data->syncCache, sizeof(SyncCache) 
                    + data->syncCache->allocated * sizeof(SyncCacheItem));
    }

    return data->syncCache;
}

_objc_pthread_data *_objc_fetch_pthread_data(bool create)
{
    _objc_pthread_data *data;

    data = (_objc_pthread_data *)tls_get(_objc_pthread_key);
    if (!data  &&  create) {
        data = (_objc_pthread_data *)
            calloc(1, sizeof(_objc_pthread_data));
        tls_set(_objc_pthread_key, data);
    }

    return data;
}
```

- 最终从全局变量中获取链表，再遍历链表查询`SyncData`，这些操作将在`lockp`锁包围的临界区中

```objc

lockp->lock();

spinlock_t *lockp = &LOCK_FOR_OBJ(object);
SyncData **listp = &LIST_FOR_OBJ(object);

SyncData* p;
SyncData* firstUnused = NULL;
for (p = *listp; p != NULL; p = p->nextData) {
    if ( p->object == object ) {
        result = p;
        // atomic because may collide with concurrent RELEASE
        OSAtomicIncrement32Barrier(&result->threadCount);
        goto done;
    }
    if ( (firstUnused == NULL) && (p->threadCount == 0) )
        firstUnused = p;
}

....


lockp->unlock();
```

**如果能在线程的本地缓存中查找到SyncData,说明是同一个线程的递归加锁或者解锁；如果不能，则说明是其他线程请求锁**

### 3.2 创建SyncData

创建新的`SyncData`实例，并加入到链表中。这些操作将在`lockp`锁包围的临界区中

```objc
lockp->lock();

... 

posix_memalign((void **)&result, alignof(SyncData), sizeof(SyncData));
result->object = (objc_object *)object;
result->threadCount = 1;
new (&result->mutex) recursive_mutex_t(fork_unsafe_lock);
result->nextData = *listp;
*listp = result;

lockp->unlock();
```

### 3.3 在缓存中存在SyncData

如果能在缓存中查找到SyncData,说明是同一个线程的递归加锁递归解锁或者其他线程请求锁，此时要自增`threadcount`或者自减`threadCount`



## 总结

`@synchronized`锁依靠`SyncData`结构体实现互斥。`SyncData` 将保存在全局的8个链表，同时缓存在线程的本地缓存中。

如果在同一个线程中使用`@synchronized`，速度会很快，因为只需要在线程的本地缓存中快速读取和更新`SyncData`。

但是如果存在许多个线程同时竞争`@synchronized`，就会需要花费大量的时间在链表查询上，同时链表的操作也需要对应的自旋锁保证线程同步。



