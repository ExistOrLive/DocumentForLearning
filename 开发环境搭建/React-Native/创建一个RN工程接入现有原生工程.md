
#### 1. 使用npm init 创建一个node 项目

```sh
npm init
```
指定项目的名称，版本，作者等等基本信息

![](https://pic.existorlive.cn//202405110057985.png)

### 2. 安装 react-native 和 react 等依赖的node库

```sh
npm install react-native

npm install react 
```

> 注意  react-native ， react 版本是否匹配

### 3. 安装开发环境依赖的node库

> **@react-native/metro-config** : metro 打包工具依赖的库

```sh 
npm install -D @react-native/metro-config
```

> **typescript** : ts 语言支持包 
### 4. package.json 的最初配置

```json
{
  "name": "NewProject",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "ios": "react-native run-ios",
    "lint": "eslint .",
    "start": "react-native start",
    "test": "jest"
  },
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.74.1"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@babel/preset-env": "^7.20.0",
    "@babel/runtime": "^7.20.0",
    "@react-native/babel-preset": "0.74.83",
    "@react-native/eslint-config": "0.74.83",
    "@react-native/metro-config": "0.74.83",
    "@react-native/typescript-config": "0.74.83",
    "@types/react": "^18.2.6",
    "@types/react-test-renderer": "^18.0.0",
    "babel-jest": "^29.6.3",
    "eslint": "^8.19.0",
    "jest": "^29.6.3",
    "prettier": "2.8.8",
    "react-test-renderer": "18.2.0",
    "typescript": "5.0.4"
  },
  "engines": {
    "node": ">=18"
  }
}
```

### 4. 添加必要的配置文件

- **metro.config.js** : metro 打包工具的配置文件


![](https://pic.existorlive.cn//202405110122172.png)


### 3. 在iOS原生项目中添加 rn的依赖