
## 注册 Activity

```xml
<application>
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
</application>

```

#### 入口Activity

`<action android:name="android.intent.action.MAIN" /><category android:name="android.intent.category.LAUNCHER" />`