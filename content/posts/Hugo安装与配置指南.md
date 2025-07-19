---
title: Hugo安装与配置指南
tags:
  - 部署
  - 博客框架
  - Hugo
  - tech
date: 2024-04-28 23:32:00
---

[Hugo](https://gohugo.io/) 是最流行的静态站点生成器之一。

# 安装
我这里使用的是 Windows 平台，安装版本为 [hugo_0.125.4_windows-amd64.zip](https://github.com/gohugoio/hugo/releases/tag/v0.125.4)。下载的压缩包中有一个名为 hugo.exe 的文件，可以使用 PowerShell 进入其所在目录执行，也可以把它添加到**环境变量**。

执行 `hugo version`，看到类似的输出则代表安装成功。
```bash
PS C:\> hugo version
hugo v0.125.4-cc3574ef4f41fccbe88d9443ed066eb10867ada2 windows/amd64 BuildDate=2024-04-25T13:27:26Z VendorInfo=gohugoio
```

`macOS` 用户可以使用包管理器 `Homebrew` 进行安装。
```bash
brew install hugo
```

# 创建网站
```bash
hugo new site myblog
```

生成的 myblog 目录结构如下：
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         2024/4/28     23:43                archetypes
d-----         2024/4/28     23:43                assets
d-----         2024/4/28     23:43                content
d-----         2024/4/28     23:43                data
d-----         2024/4/28     23:43                i18n
d-----         2024/4/28     23:43                layouts
d-----         2024/4/28     23:43                static
d-----         2024/4/28     23:43                themes
-a----         2024/4/28     23:43             83 hugo.toml
```

# 安装主题
可以到 Hugo 官方的[主题商店](https://themes.gohugo.io/)选择自己心仪的主题。这里以[Archie - Hugo theme](https://themes.gohugo.io/themes/archie/)为例演示：
```bash
mkdir themes 
cd themes 
git clone https://github.com/athul/archie.git
```
然后在网站根目录的 `hugo.toml` 中增加 `theme="archie"`。

# 启动博客
```bash
hugo server --buildDrafts
```
如果没有在 `hugo.toml` 中配置主题，也可以在启动时用 `-t` 指定：
```bash
hugo server -t archie --buildDrafts
```

# 新建文章
```bash
hugo new post/post.md
```
执行后，`content/post` 目录会生成 `post.md`。在`post.md`中填写内容后，再次执行 `hugo server --buildDrafts`，即可看到文章已经成功生成。

# 部署到 Github
首先创建一个新仓库，仓库名一定要是`你的Github用户名.github.io`。

仓库创建完成后，再使用下面的命令生成网站。我这里用的 `baseURL` 是自己的项目地址，大家在部署时需要替换成自己的。
```bash
hugo --theme=archie --baseURL="https://lbzzyz.github.io/" --buildDrafts
```
上述命令执行完成后，会在网站根目录生成一个 `public` 文件夹，这就是网站的最终产物。

接下来，我们需要把 public 文件夹上传到 Github 仓库，以便用 Github 访问。
```bash
cd public
git init
git add .
git commit -m "Hugo init"
git remote add origin https://github.com/LBZZYZ/lbzzyz.github.io.git
git push -u origin master
```
网站产物已经推送到刚才创建的 Github 仓库，此时我们访问 [https://lbzzyz.github.io](https://lbzzyz.github.io)，即可看到看到网站内容了。

# 笔记与博客独立管理
我希望笔记可以使用纯 `Markdown` 格式保存，并且与 `Hugo` 等第三方框架产生的文件独立管理。因此这里使用 Git 的[子模块](https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E5%AD%90%E6%A8%A1%E5%9D%97)实现。

```bash
git submodule add https://github.com/LBZZYZ/WorkNotes.git content/post
git add .
git commit -m 'add submodule'
git push
```

这条命令可以为当前项目添加一个子模块，最后的 `content/post` 参数是制定项目克隆到哪里，缺省时代表克隆到当前目录。由于 `archie` 主题的博客文件都是放到 `content/post` 中，因此我们制定把笔记克隆到这里。

由于引入了子模块，在拉取仓库代码时需要加入 `--recursive` 关键字，即 `git clone --recursive your-repo.git`。针对已经拉取到本地的代码，也可以执行下面的步骤同步子模块：

1. 初始化本地子模块配置文件：`git submodule init`；
2. 更新项目，抓取子模块内容：`git submodule update --remote`。

也可以将这两步命令合并为一步：`git submodule update --init --remote`。