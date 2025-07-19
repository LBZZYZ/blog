#!/bin/bash

POSTS_WITH_GIT=false

THEME="typo"
BASE_URL="https://www.libingzhi.top/"

TAR_NAME="blog.tar.gz"
TAR_LOCAL_DIR="./$TAR_NAME"

POSTS_LOCAL_DIR="./content/posts"
TARGET_LOCAL_DIR="./public"
TARGET_REMOTE_DIR="/root/nginx/html"

ADDR="root@47.119.119.139"

# 函数：检查命令是否执行成功
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: Command '\$1' failed. Exiting..."
        exit 1
    fi
}

# 清理操作
echo "Cleaning up old files..."
rm -f "$TAR_LOCAL_DIR"
rm -rf "$TARGET_LOCAL_DIR"

# 更新文章
if [ $POSTS_WITH_GIT ];
then
    echo "Updating posts from Git..."
    cd "$POSTS_LOCAL_DIR" || exit
    git clean -df
    git checkout main
    git pull --rebase
    check_command "git pull"
fi

# 返回根目录
cd - || exit

# 生成博客静态文件
echo "Building Hugo site..."
hugo --theme="$THEME" --baseURL="$BASE_URL" --buildDrafts
check_command "hugo build"

# 创建压缩包
echo "Creating tarball..."
tar -zcf "$TAR_LOCAL_DIR" $TARGET_LOCAL_DIR/
check_command "tar"

# 清空服务器 html 目录
ssh $ADDR "rm -rf $TARGET_REMOTE_DIR/*"

# 上传压缩包到远程服务器
echo "Uploading blog.tar to remote server..."
scp "$TAR_LOCAL_DIR" "$ADDR:$TARGET_REMOTE_DIR"
check_command "scp"

# 远程执行脚本
echo "Executing remote blog script..."
ssh $ADDR "cd $TARGET_REMOTE_DIR && tar -zxf $TAR_NAME --strip-components=2 && rm $TAR_NAME"
check_command "ssh"

# 清除本地产物
rm -f "$TAR_LOCAL_DIR"

echo "Blog deployment completed successfully!"
