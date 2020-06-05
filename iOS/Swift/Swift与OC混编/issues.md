# NSClassFromString

在OC可以通过`NSClassFromString`方法传入类名获取类对象；而在Swift中，一个类的完全限定类名还需要包括模块名。

例如：

```objc
// _TtC14ZLGitHubClient21ZLAboutViewController

NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
                    
NSString *classStringName = [NSString stringWithFormat:@"_TtC%lu%@%lu%@", (unsigned long)appName.length, appName, (unsigned long)classString.length, classString];
                    
cla = NSClassFromString(classStringName);


```

```swift

if  var appName: String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as String? {

// generate the full name of your class (take a look into your "YourProject-swift.h" file)
let classStringName = "_TtC\(appName!.count)\(appName)\(className.count))\(className)"
// return the class!
let cla = NSClassFromString(classStringName)
}


```
[Stack Overflow : Swift language NSClassFromString][1]


[1]: https://stackoverflow.com/questions/24030814/swift-language-nsclassfromstring