# Alfred 自定义工作流

## 其他人的workflow:

1. Better Dictionsary: <https://github.com/mr-pennyworth/alfred-better-dictionaries>

## 如何安装 all-in-one 工作流

```bash
cd ~/.config/alfred-workflows/all-in-one
./install.sh
```

安装之后，需要在 workflow 中配置 deepl key

然后设置一些动作显示在 Fallback 结果中：

[设置]-> [Features] -> [Default Results] -> [Fallbacks] -> [Setup fallback results] -> [Add default workflow trigger] -> [添加你需要的默认trigger]

## 如何新建一个可维护的 alfred workflow 工作流

[source](https://www.alfredforum.com/topic/9251-what-is-your-workflow-for-developing-these-workflows/)

1. 为项目创建一个新目录，其中包含一个 "project-name "子目录。
2. 在 Alfred 中创建一个新的、空的工作流程。
3. 在 Alfred 的用户界面中配置工作流程的名称、捆绑 ID 和图标等。
4. 在 Finder 中显示工作流程。
5. 将所有内容移至新项目的 "project-name "子目录。
6. 从 Alfred 中删除工作流程。
7. 从项目目录链接工作流程： workflow-install -s project-name

## dev

```
node --test ~/.config/alfred-workflows/all-in-one/translate.test.mjs
```
