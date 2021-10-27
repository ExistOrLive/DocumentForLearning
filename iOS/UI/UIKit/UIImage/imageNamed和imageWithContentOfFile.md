# UIImage

> An object that manages image data in your app. 



## Tip.1 `+imageNamed:` 和 `imageWithContentOfFile:`的区别

- `+imageNamed:`
> This method looks in the system caches for an image object with the specified name and returns that object if it exists. If a matching image object is not already in the cache, this method locates and loads the image data from disk or asset catelog, and then returns the resulting object. You can not assume that this method is thread safe.

 使用这个方法加载图片，会先从系统缓存中寻找是否有指定名称的图片。如果有，就直接返回；如果没有，就会从Main Bundle中加载图片，并缓存到系统的缓存中，然后返回。
 
 因此，这个方法适合内存占用较小，反复使用的图片


- `imageWithContentOfFile:`
   这种方法不会缓存加载好的图片，适合于图片资源较大或者使用频率较低的图片




