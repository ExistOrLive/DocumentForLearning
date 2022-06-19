## NSInternalInconsistencyException 之 Invalid parameter not satisfying: pos

#crash

用户切到后台去复制地址，然后回到页面做textView 的粘贴动作，由于系统iOS15 textView 的bug导致发生的崩溃

### 解决方案

实现 `UITextPasteDelegate` 的方法：

```swift

func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, performPasteOf attributedString: NSAttributedString, to textRange: UITextRange) -> UITextRange {

  }
```


[Invalid parameter not satisfying: pos Crash on iOS 15 while pasting text onto UITextView](https://varun04tomar.medium.com/invalid-parameter-not-satisfying-po-crash-on-ios-15-while-pasting-text-onto-uitextview-57e94bbca113)

[iOS15 UITextView After dragging the view, it causes a crash, Invalid parameter not satisfying: pos](https://stackoverflow.com/questions/69568511/ios15-uitextview-after-dragging-the-view-it-causes-a-crash-invalid-parameter-n)