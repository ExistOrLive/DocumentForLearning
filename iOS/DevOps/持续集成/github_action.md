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

on:                               # 触发条件
  push:
    branches:
      - master
  pull_request:
    branches:
      - master

jobs:
  build:
    name: build
    runs-on: macos-latest # runner 系统 
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
    - name: upload github artifact
      if: success()
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

- run 
  
  run选项 可以直接指定运行的指令

- uses
  
  uses选项 可以使用github marketplace中发布的action

- working-directory
  
  working-directory 指定脚本的执行目录

- env
  
  env选项指定脚本执行的环境变量


## Tips

1. 在workflow中可能会使用token，secret-key这样的私密信息，无法明文写在配置文件中。 这些信息可以在repository的setting配置为secret,然后在step中配置为env

![][6]

![][7]

2. workflow 默认在工程的根目录下执行，如果希望在其他目录执行，需要指定step的working-directory















[1]: http://www.ruanyifeng.com/blog/2019/09/getting-started-with-github-actions.html

[2]:pic/github_action1.png

[3]: https://help.github.com/en/actions

[4]: https://github.com/MengAndJie/GithubClient

[5]: https://help.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events-schedule

[6]: pic/github_action2.png

[7]: pic/github_action3.png
