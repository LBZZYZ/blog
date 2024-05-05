#!/bin/bash

# 函数：处理单个文件
process_file() {
    local file="$1"
    # 提取文件名（不含后缀名）
    filename=$(basename "$file" | sed 's/\.[^.]*$//')
    # 检查是否已经存在title
    title_check=$(sed -n '/^title: /p' "$file")
    if [ -z "$title_check" ]; then
        # 检查文件首行是否以 --- 开始
        first_line=$(sed -n '1p' "$file")
        if [[ "$first_line" != "---" ]]; then
            # 如果不是以 --- 开始，则在文件首行插入 --- 和换行符
            sed -i '' '1i\
---\
' "$file"
        fi

        # 在文件中查找第一个 --- ，在其后插入 title: 文件名 和换行符
        delimiter=$(sed -n '/^---/=' "$file" | head -n 1)
        if [ -n "$delimiter" ]; then
            sed -i '' "${delimiter}a\\
title: $filename
" "$file"
        fi
if [[ "$first_line" != "---" ]]; then
        # 在 title 后再插入一个 --- 和换行符
        sed -i '' "/^title: /a\\
---
" "$file"
fi
    fi
}

# 函数：递归处理文件夹
process_folder() {
    local folder="$1"
    # 进入文件夹
    cd "$folder" || return
    # 遍历文件夹中的每个文件和子文件夹
    for item in *; do
        if [ -d "$item" ]; then
            # 如果是文件夹，则递归处理
            process_folder "$item"
        elif [ -f "$item" ] && [[ "$item" == *.md ]]; then
            # 如果是.md文件，则处理
            process_file "$item"
        fi
    done
    # 返回上级目录
    cd ..
}

# 获取当前目录
current_dir=$(pwd)

# 处理当前目录
process_folder "$current_dir"
