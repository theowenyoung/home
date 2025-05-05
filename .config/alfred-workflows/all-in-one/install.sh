#!/bin/bash

# 获取当前脚本所在的绝对路径
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 设置 Alfred Workflow 目录
ALFRED_WORKFLOWS_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"

# 检查 info.plist 是否存在
INFO_PLIST="$SOURCE_DIR/info.plist"
if [ ! -f "$INFO_PLIST" ]; then
  echo "错误: 在 $SOURCE_DIR 中找不到 info.plist 文件"
  exit 1
fi

# 从 info.plist 提取 bundleid (workflow ID)
# 使用 grep 和 sed 从 plist 中提取 bundleid
WORKFLOW_ID=$(grep -A 1 "<key>bundleid</key>" "$INFO_PLIST" | grep "<string>" | sed -E 's/.*<string>(.*)<\/string>.*/\1/')

# 如果无法提取 bundleid，使用目录名作为后备
if [ -z "$WORKFLOW_ID" ]; then
  echo "警告: 无法从 info.plist 中提取 bundleid，将使用目录名作为 workflow ID"
  WORKFLOW_ID="com.custom.$(basename "$SOURCE_DIR")"
fi

echo "使用 Workflow ID: $WORKFLOW_ID"
TARGET_PATH="$ALFRED_WORKFLOWS_DIR/$WORKFLOW_ID"

# 确保 Alfred workflows 目录存在
mkdir -p "$ALFRED_WORKFLOWS_DIR"

# 检查目标路径是否已存在，如果存在则删除
if [ -e "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
  echo "删除现有链接或目录: $TARGET_PATH"
  rm -rf "$TARGET_PATH"
fi

# 创建软链接
ln -s "$SOURCE_DIR" "$TARGET_PATH"

# 检查是否成功
if [ $? -eq 0 ]; then
  echo "已成功创建软链接:"
  echo "源: $SOURCE_DIR"
  echo "目标: $TARGET_PATH"
else
  echo "创建软链接失败"
  exit 1
fi
