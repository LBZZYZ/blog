#!/bin/bash

# 设置变量
BLOG_TAR="./blog.tar.gz"

PUBLIC_DIR="./public"

POSTS_DIR="./content/posts"

REMOTE_SERVER="root@47.119.119.139:/root/nginx/html"

REMOTE_SCRIPT="root@47.119.119.139:/home/simon/blog.sh"

HUGO_THEME="typo"

BASE_URL="https://www.libingzhi.top/"

# 函数：检查命令是否执行成功
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: Command '\$1' failed. Exiting..."
        exit 1
    fi
}

# 清理操作
echo "Cleaning up old files..."
rm -f "$BLOG_TAR"
rm -rf "$PUBLIC_DIR"

# 切换到 posts 目录并更新 Git
echo "Updating posts from Git..."
cd "$POSTS_DIR" || exit
git clean -df
git checkout main
git pull --rebase
check_command "git pull"

# 返回根目录
cd - || exit

# 生成博客静态文件
echo "Building Hugo site..."
hugo --theme="$HUGO_THEME" --baseURL="$BASE_URL" --buildDrafts
check_command "hugo build"

# 创建压缩包
echo "Creating tarball..."
tar -zcvf "$BLOG_TAR" ./public/
check_command "tar"

# 清空服务器 html 目录
ssh root@47.119.119.139 "rm -rf /root/nginx/html/*"

# 上传压缩包到远程服务器
echo "Uploading blog.tar to remote server..."
scp "$BLOG_TAR" "$REMOTE_SERVER"
check_command "scp"

# 远程执行脚本
echo "Executing remote blog script..."
ssh root@47.119.119.139 "cd /root/nginx/html && tar -zxvf blog.tar.gz --strip-components=2 && rm blog.tar.gz"
check_command "ssh"

echo "Blog deployment completed successfully!"
