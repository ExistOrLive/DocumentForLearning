# UIEvent

`UIEvent`是描述用户与app的一次交互的对象

## Event的类型

iOS系统在运行过程中，会收到各种不同的事件，包括`touch事件`，`motion事件`，`remote control事件`以及`press 事件`。

- `touch事件`指的是用户与屏幕间的交互，包括点击，长按等。

- `motion事件`指的是设备运动相关的事件，例如摇一摇等;

- `remote control`事件指的是收到外设(例如耳机)发出的命令，例如耳机控制音视频的播放;

- `press 事件`指的是游戏手柄，apple TV遥控器等有物理按钮的设备间的交互。


`UIEvent`通过`type`和`subType`属性区分不同类型的事件。

``` objc

typedef NS_ENUM(NSInteger, UIEventType) {
    UIEventTypeTouches,
    UIEventTypeMotion,
    UIEventTypeRemoteControl,
    UIEventTypePresses API_AVAILABLE(ios(9.0)),
};

@property(nonatomic,readonly) UIEventType     type API_AVAILABLE(ios(3.0));
@property(nonatomic,readonly) UIEventSubtype  subtype API_AVAILABLE(ios(3.0));

```

## UITouch

`UITouch` 是一个描述点击屏幕的位置，范围，移动以及压力的对象。



```objc
@property(nonatomic, readonly, nullable) NSSet <UITouch *> *allTouches;

```