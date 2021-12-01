# Github Action

> Github Action 是 Github 提供的 持续集成服务。因此只有保存在Github上的工程才可以使用。

> Github Action的配置在工程的主目录下的.github/workflows目录下的yaml文件中

![][2]

> 在yaml配置文件中可以配置action的触发条件,运行环境，具体执行的操作。

更具体的操作请参考[Github Action 入门教程][1]，[Github Action官方文档][3]

## GitHub Action中的概念

1. `workflow` （工作流程）：持续集成一次运行的过程，就是一个 workflow。

2. `job` （任务）：一个 workflow 由一个或多个 jobs 构成，含义是一次持续集成的运行，可以完成多个任务。

3. `step`（步骤）：每个 job 由多个 step 构成，一步步完成。

4. `action` （动作）：每个 step 可以依次执行一个或多个命令（action）。

## ZLGithubClient 自动化打包实践

> [GithubClient][4]工程在`.github/workflows/build.yml`配置了自动打包并上传制品库的workflow。

```yml
# action 语法 https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions
name: ZLGithub Build

on:                                       # 触发条件 当master分支发生push和pr事件时，触发
  push:
    branches:
      - master
  pull_request:
    branches:
      - master

jobs:              
  build:                                  # 仅有一个job build
    name: build                           # job的name
    runs-on: macos-latest                 # runner 运行系统 macos
    steps:                                
    - name: checkout                      # step的名字          
      uses: actions/checkout@v2.0.0       # step使用的action 
      with: 
        ref: master 
    - name: construct build enviroment
      working-directory: ./ZLGitHubClient          # 指定step 的工作目录
      run: |                              # step 执行的脚本
        gem cleanup
        gem install bundler
        bundle install
        pod repo update
        pod install
        echo "construct build enviroment success"
    - name: archive app
      working-directory: ./ZLGitHubClient          # 指定step 的工作目录
      env:                                         # 指定step 执行脚本的环境变量
        MATCH_KEYCHAIN_NAME: ${{ secrets.MATCH_KEYCHAIN_NAME }}
        MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        MATCH_GITHUB_URL: ${{ secrets.MATCH_GITHUB_URL }}
      run: |
        pwd 
        bundle exec fastlane github_action_adhoc
        echo "ipa build success"
    - name: upload github artifact
      if: success()                               # 当前step执行的条件是上一次step执行成功
      uses: actions/upload-artifact@v1.0.0
      with:
          # Artifact name
          name: ZLGitHubClient
          # Directory containing files to upload
          path: ./ZLGitHubClient/fastlane/ipa
    - name: upload artifact
      working-directory: ./ZLGitHubClient          # 指定run 的工作目录
      if: success()
      env: 
        CODING_ARTIFACT_TOKEN: ${{ secrets.CODING_ARTIFACT_TOKEN }}
      run: |
        curl -T ./fastlane/ipa/ZLGitHubClient.ipa  -u $CODING_ARTIFACT_TOKEN  "https://existorlive-generic.pkg.coding.net/ZLGitHubClient/adhoc/ZLGitHubClient.ipa" -v                    # 上传ipa到制品库
        echo "work flow build end"
```

### name 

> name选项 配置workflow的名字

### on

> `on`选项 配置workflow的触发条件,也就是GitHub的各种事件，如下配置了当master分支发生了push和push_request事件时会触发

```yml
on:                               # 触发条件
  push:
    branches:
      - master
  pull_request:
    branches:
      - master
```

> 也可以配置定时触发

```yml

on:
  schedule:
    # * is a special character in YAML so you have to quote this string
    - cron:  '*/15 * * * *'
```

[Events that trigger workflows][5]

### jobs

> `jobs选项` 定义了workflow中的各种任务。workflow由一个或多个任务组成。默认情况下，任务并行运行。要顺序运行任务，可以使用`job.<job_id>.needs`选项定义对其他任务的依赖关系。

如下，配置了analyse，build，test，deploy四个job

```yml
jobs:
  - analyse:
      name: analyse
      runs-on: macos-latest
      steps: 
      - 


  - build:
      name: build
      needs: analyse

  - test:
      name: test
      needs: [analyse,build]

  - deploy:
      name: deploy
      needs: [analyse,build,deploy]

```
- name 
   
   name 即job的名字

- needs 
   
   needs 表示当前job执行的条件是某几个job执行完成,如上所示build依赖于analyse执行完成

- runs-on
    
    runs-on 表示当前job的执行环境

- steps

    steps 表示当前job的执行步骤

### steps
 
> steps代表jobs中的步骤，step可以自定义脚本，也可以使用他人编译好的脚本，在github marketplace中发布和查询。

```yml

steps:
    - name: checkout
      uses: actions/checkout@v2.0.0
      with: 
        ref: master 
    - name: construct build enviroment
      working-directory: ./ZLGitHubClient          # 指定run 的工作目录
      run: |
        gem cleanup
        gem install bundler
        bundle install
        pod repo update
        pod install
        echo "construct build enviroment success"
    - name: archive app
      working-directory: ./ZLGitHubClient          # 指定run 的工作目录
      env: 
        MATCH_KEYCHAIN_NAME: ${{ secrets.MATCH_KEYCHAIN_NAME }}
        MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        MATCH_GITHUB_URL: ${{ secrets.MATCH_GITHUB_URL }}
      run: |
        pwd 
        bundle exec fastlane github_action_adhoc
        echo "ipa build success"

```

- name 
 
  name选型 step的名字

- run 
  
  run选项 可以直接指定运行的指令

- uses
  
  uses选项 可以使用github marketplace中发布的action

- working-directory
  
  working-directory 指定脚本的执行目录

- env
  
  env选项指定脚本执行的环境变量
  
- if
  
  if选项 指定当前step运行的条件


## Tips

1. 在workflow中可能会使用token，secret-key这样的私密信息，无法明文写在配置文件中。 这些信息可以在repository的setting配置为secret,然后在step中配置为env

![][6]

![][7]

2. workflow 默认在工程的根目录下执行，如果希望在其他目录执行，需要指定step的working-directory


## ENV

默认配置的环境变量：

- GITHUB_SHA : 触发workflow的 commit sha

- GITHUB_REF : 触发workflow的 ref

```
GITHUB_JOB : build
GITHUB_EVENT_PATH : /Users/runner/work/_temp/_github_workflow/event.json
RUNNER_OS : macOS
XCODE_12_DEVELOPER_DIR : /Applications/Xcode_12.5.1.app/Contents/Developer
GITHUB_BASE_REF : 
NVM_CD_FLAGS : 
ANDROID_HOME : /Users/runner/Library/Android/sdk
SHELL : /bin/bash
GOROOT_1_17_X64 : /Users/runner/hostedtoolcache/go/1.17.3/x64
CHROMEWEBDRIVER : /usr/local/Caskroom/chromedriver/96.0.4664.45
GITHUB_REF_NAME : function_ci
PIPX_BIN_DIR : /usr/local/opt/pipx_bin
GITHUB_REPOSITORY_OWNER : MengAndJie
TMPDIR : /var/folders/24/8k48jl6d249_n_qfxwsl6xvm0000gn/T/
RUNNER_ARCH : X64
GITHUB_RUN_ATTEMPT : 1
GITHUB_RUN_NUMBER : 9
GITHUB_ACTIONS : true
ANDROID_SDK_ROOT : /Users/runner/Library/Android/sdk
RUNNER_WORKSPACE : /Users/runner/work/GithubClient
GITHUB_REF_PROTECTED : false
JAVA_HOME_8_X64 : /Users/runner/hostedtoolcache/Java_Temurin-Hotspot_jdk/8.0.312-7/x64/Contents/Home/
RCT_NO_LAUNCH_PACKAGER : 1
NUNIT_BASE_PATH : /Library/Developer/nunit
RUNNER_PERFLOG : /usr/local/opt/runner/perflog
GITHUB_WORKFLOW : ZLGithub Test
GITHUB_REF : refs/heads/function_ci
LC_ALL : en_US.UTF-8
NUNIT3_PATH : /Library/Developer/nunit/3.6.0
NOREPLEY_PWD : ***
JAVA_HOME_11_X64 : /Users/runner/hostedtoolcache/Java_Temurin-Hotspot_jdk/11.0.13-8/x64/Contents/Home/
RUNNER_TOOL_CACHE : /Users/runner/hostedtoolcache
GITHUB_ACTION_REPOSITORY : 
NVM_DIR : /Users/runner/.nvm
USER : runner
GITHUB_REF_TYPE : branch
GITHUB_API_URL : https://api.github.com
GITHUB_EVENT_NAME : push
GITHUB_SHA : 489d0ba0e2f9897ba06fbd21e028516e90ecb009
RUNNER_TEMP : /Users/runner/work/_temp
RUNNER_NAME : GitHub Actions 2
ANDROID_NDK_ROOT : /Users/runner/Library/Android/sdk/ndk-bundle
ANDROID_NDK_LATEST_HOME : /Users/runner/Library/Android/sdk/ndk/23.1.7779620
ImageVersion : 20211120.1
SSH_AUTH_SOCK : /private/tmp/com.apple.launchd.YVJpCU1HKF/Listeners
GITHUB_SERVER_URL : https://github.com
__CF_USER_TEXT_ENCODING : 0x1F5:0:0
HOMEBREW_NO_AUTO_UPDATE : 1
GITHUB_HEAD_REF : 
AGENT_TOOLSDIRECTORY : /Users/runner/hostedtoolcache
GITHUB_GRAPHQL_URL : https://api.github.com/graphql
JAVA_HOME_17_X64 : /Users/runner/hostedtoolcache/Java_Temurin-Hotspot_jdk/17.0.1-12/x64/Contents/Home/
PATH : /usr/local/lib/ruby/gems/2.7.0/bin:/usr/local/opt/ruby@2.7/bin:/usr/local/opt/pipx_bin:/Users/runner/.cargo/bin:/usr/local/opt/curl/bin:/usr/local/bin:/usr/local/sbin:/Users/runner/bin:/Users/runner/.yarn/bin:/Users/runner/Library/Android/sdk/tools:/Users/runner/Library/Android/sdk/platform-tools:/Users/runner/Library/Android/sdk/ndk-bundle:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/usr/bin:/bin:/usr/sbin:/sbin:/Users/runner/.dotnet/tools:/Users/runner/.ghcup/bin:/Users/runner/hostedtoolcache/stack/2.7.3/x64
_ : /usr/local/bin/python3
GITHUB_RETENTION_DAYS : 90
PERFLOG_LOCATION_SETTING : RUNNER_PERFLOG
GOROOT_1_15_X64 : /Users/runner/hostedtoolcache/go/1.15.15/x64
VM_ASSETS : /usr/local/opt/runner/scripts
EDGEWEBDRIVER : /usr/local/share/edge_driver
DOTNET_ROOT : /Users/runner/.dotnet
PWD : /Users/runner/work/GithubClient/GithubClient/ZLGitHubClient/EmailSender
CONDA : /usr/local/miniconda
JAVA_HOME : /Users/runner/hostedtoolcache/Java_Temurin-Hotspot_jdk/8.0.312-7/x64/Contents/Home/
VCPKG_INSTALLATION_ROOT : /usr/local/share/vcpkg
LANG : en_US.UTF-8
ImageOS : macos11
XCODE_13_DEVELOPER_DIR : /Applications/Xcode_13.1.app/Contents/Developer
XPC_FLAGS : 0x0
PIPX_HOME : /usr/local/opt/pipx
GITHUB_ACTOR : ExistOrLive
GECKOWEBDRIVER : /usr/local/opt/geckodriver/bin
XPC_SERVICE_NAME : 0
HOME : /Users/runner
SHLVL : 2
RUNNER_TRACKING_ID : github_a3155cac-e82e-40de-beca-8db32df81ea9
GITHUB_WORKSPACE : /Users/runner/work/GithubClient/GithubClient
GITHUB_ACTION_REF : 
CI : true
GITHUB_RUN_ID : 1510977101
Email_Receivers : ***
GOROOT_1_16_X64 : /Users/runner/hostedtoolcache/go/1.16.10/x64
LOGNAME : runner
GITHUB_ENV : /Users/runner/work/_temp/_runner_file_commands/set_env_1d5bb643-86c4-4cfe-809c-1f3b4a7aa993
LC_CTYPE : en_US.UTF-8
HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS : 3650
HOMEBREW_CASK_OPTS : --no-quarantine
POWERSHELL_DISTRIBUTION_CHANNEL : GitHub-Actions-macos11
BOOTSTRAP_HASKELL_NONINTERACTIVE : 1
ANDROID_NDK_HOME : /Users/runner/Library/Android/sdk/ndk-bundle
XCODE_11_DEVELOPER_DIR : /Applications/Xcode_11.7.app/Contents/Developer
GITHUB_REPOSITORY : MengAndJie/GithubClient
GITHUB_PATH : /Users/runner/work/_temp/_runner_file_commands/add_path_1d5bb643-86c4-4cfe-809c-1f3b4a7aa993
GITHUB_ACTION : __run
DOTNET_MULTILEVEL_LOOKUP : 0
```

[environment-variables](https://docs.github.com/en/actions/learn-github-actions/environment-variables)














[1]: http://www.ruanyifeng.com/blog/2019/09/getting-started-with-github-actions.html

[2]:pic/github_action1.png

[3]: https://help.github.com/en/actions

[4]: https://github.com/MengAndJie/GithubClient

[5]: https://help.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events-schedule

[6]: pic/github_action2.png

[7]: pic/github_action3.png
