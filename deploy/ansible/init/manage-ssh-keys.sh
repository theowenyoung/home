#!/bin/bash
# ===================================
# 通用 SSH Key 管理脚本
# 文件: files/manage-ssh-keys.sh
# ===================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
  echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️${NC} $1"
}

error() {
  echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌${NC} $1"
}

info() {
  echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️${NC} $1"
}

usage() {
  cat <<EOF
🔑 SSH Key 管理工具

用法: $0 -u <ssh_user> {add|remove|list|sync|status|backup|restore} [参数]

必需参数:
  -u <ssh_user>             SSH 用户名 (如: deploy, ubuntu)

命令:
  add <github_username>     添加单个用户
  remove <github_username>  移除单个用户
  list                      列出所有用户
  sync <user1> <user2>...   同步指定用户列表
  sync -f <file>            从文件同步用户列表
  status                    显示详细状态信息
  backup                    手动备份 authorized_keys
  restore                   从备份恢复

示例:
  $0 -u deploy add alice-dev
  $0 -u deploy remove bob-smith
  $0 -u deploy sync alice-dev bob-smith charlie-ops
  $0 -u deploy sync -f team_members.txt
  $0 -u deploy list
  $0 -u deploy status

文件格式 (team_members.txt):
  alice-dev
  bob-smith
  charlie-ops
  # 注释行会被忽略

EOF
  exit 1
}

# 解析命令行参数
parse_args() {
  SSH_USER=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      -u | --user)
        SSH_USER="$2"
        shift 2
        ;;
      -h | --help)
        usage
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ -z "$SSH_USER" ]]; then
    error "必须指定 SSH 用户名"
    echo "使用 -h 查看帮助"
    exit 1
  fi

  AUTHORIZED_KEYS="/home/$SSH_USER/.ssh/authorized_keys"

  # 返回剩余的参数
  COMMAND="$1"
  shift
  ARGS=("$@")
}

# 检查权限
check_permissions() {
  if [[ $EUID -ne 0 ]]; then
    error "此脚本需要 root 权限运行"
    echo "请使用: sudo $0 $*"
    exit 1
  fi

  if [[ ! -d "/home/$SSH_USER" ]]; then
    error "用户 $SSH_USER 的家目录不存在"
    exit 1
  fi

  if [[ ! -d "/home/$SSH_USER/.ssh" ]]; then
    warn "用户 $SSH_USER 的 .ssh 目录不存在，正在创建..."
    mkdir -p "/home/$SSH_USER/.ssh"
    chown "$SSH_USER:$SSH_USER" "/home/$SSH_USER/.ssh"
    chmod 700 "/home/$SSH_USER/.ssh"
  fi
}

# 创建备份
create_backup() {
  local backup_file="${AUTHORIZED_KEYS}.backup.$(date +%Y%m%d_%H%M%S)"

  if [[ -f "$AUTHORIZED_KEYS" ]]; then
    cp "$AUTHORIZED_KEYS" "$backup_file"
    info "备份保存到: $backup_file"
    return 0
  else
    warn "authorized_keys 文件不存在，跳过备份"
    return 1
  fi
}

# 设置文件权限
fix_permissions() {
  if [[ ! -f "$AUTHORIZED_KEYS" ]]; then
    touch "$AUTHORIZED_KEYS"
  fi

  chown "$SSH_USER:$SSH_USER" "$AUTHORIZED_KEYS"
  chmod 600 "$AUTHORIZED_KEYS"
}

# 验证 GitHub 用户名
validate_github_user() {
  local github_user=$1

  if [[ -z "$github_user" ]]; then
    error "GitHub 用户名不能为空"
    return 1
  fi

  # GitHub 用户名规则：只能包含字母数字和连字符，不能以连字符开头或结尾
  if [[ ! "$github_user" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
    error "无效的 GitHub 用户名: $github_user"
    return 1
  fi

  return 0
}

# 获取 GitHub SSH keys
get_github_keys() {
  local github_user=$1
  local keys

  info "正在获取 $github_user 的 SSH keys..."

  keys=$(curl -sf --connect-timeout 10 --max-time 30 "https://github.com/${github_user}.keys" 2>/dev/null)

  if [[ $? -eq 0 && -n "$keys" ]]; then
    echo "$keys"
    return 0
  else
    return 1
  fi
}

# 添加用户
add_user() {
  local github_user=$1

  if ! validate_github_user "$github_user"; then
    return 1
  fi

  log "添加用户: $github_user (SSH用户: $SSH_USER)"

  # 检查是否已存在
  if grep -q "team-${github_user}-" "$AUTHORIZED_KEYS" 2>/dev/null; then
    warn "用户 $github_user 已存在，将覆盖现有 keys"
    remove_user "$github_user"
  fi

  # 获取并添加 SSH keys
  local keys
  if keys=$(get_github_keys "$github_user"); then
    create_backup >/dev/null

    local key_count=0
    while IFS= read -r key; do
      if [[ -n "$key" && ! "$key" =~ ^# ]]; then
        echo "$key team-$github_user-$(date +%Y%m%d)" >>"$AUTHORIZED_KEYS"
        ((key_count++))
      fi
    done <<<"$keys"

    fix_permissions
    log "✅ 用户 $github_user 添加成功 ($key_count 个 keys)"
  else
    error "无法获取 $github_user 的 SSH keys"
    return 1
  fi
}

# 移除用户
remove_user() {
  local github_user=$1

  if ! validate_github_user "$github_user"; then
    return 1
  fi

  log "移除用户: $github_user"

  if [[ -f "$AUTHORIZED_KEYS" ]] && grep -q "team-${github_user}-" "$AUTHORIZED_KEYS"; then
    create_backup >/dev/null
    sed -i "/ team-${github_user}-/d" "$AUTHORIZED_KEYS"
    fix_permissions
    log "✅ 用户 $github_user 移除成功"
  else
    warn "用户 $github_user 不存在"
    return 1
  fi
}

# 列出用户
list_users() {
  if [[ ! -f "$AUTHORIZED_KEYS" ]]; then
    warn "authorized_keys 文件不存在"
    return 1
  fi

  echo "=== 当前团队成员 (SSH用户: $SSH_USER) ==="

  local users
  users=$(grep "team-" "$AUTHORIZED_KEYS" 2>/dev/null | sed 's/.* team-\([^-]*\)-.*/\1/' | sort | uniq)

  if [[ -n "$users" ]]; then
    echo "$users" | nl
    echo ""
    echo "总计: $(echo "$users" | wc -l) 人"
  else
    echo "暂无团队成员"
  fi
}

# 显示状态
show_status() {
  echo "=== SSH Key 管理状态 ==="
  echo "SSH 用户: $SSH_USER"
  echo "authorized_keys 路径: $AUTHORIZED_KEYS"
  echo ""

  if [[ -f "$AUTHORIZED_KEYS" ]]; then
    echo "authorized_keys 文件:"
    echo "  - 存在: ✅"
    echo "  - 大小: $(stat -c%s "$AUTHORIZED_KEYS") 字节"
    echo "  - 权限: $(stat -c%a "$AUTHORIZED_KEYS")"
    echo "  - 所有者: $(stat -c%U:%G "$AUTHORIZED_KEYS")"
    echo "  - 修改时间: $(stat -c%y "$AUTHORIZED_KEYS")"
    echo ""

    local total_keys=$(wc -l <"$AUTHORIZED_KEYS")
    local team_keys=$(grep -c "team-" "$AUTHORIZED_KEYS" 2>/dev/null || echo 0)
    local other_keys=$((total_keys - team_keys))

    echo "SSH Keys 统计:"
    echo "  - 总 keys: $total_keys"
    echo "  - 团队 keys: $team_keys"
    echo "  - 其他 keys: $other_keys"
  else
    echo "authorized_keys 文件: ❌ 不存在"
  fi

  echo ""
  echo "可用备份文件:"
  ls -la "${AUTHORIZED_KEYS}".backup.* 2>/dev/null | tail -5 || echo "  无备份文件"
}

# 从文件读取用户列表
read_users_from_file() {
  local file=$1
  local users=()

  if [[ ! -f "$file" ]]; then
    error "文件不存在: $file"
    return 1
  fi

  while IFS= read -r line; do
    # 跳过空行和注释
    line=$(echo "$line" | xargs) # 去除前后空白
    if [[ -n "$line" && ! "$line" =~ ^# ]]; then
      users+=("$line")
    fi
  done <"$file"

  if [[ ${#users[@]} -eq 0 ]]; then
    error "文件中没有找到有效的用户名: $file"
    return 1
  fi

  echo "${users[@]}"
  return 0
}

# 同步用户列表
sync_users() {
  local users=()

  # 解析参数
  if [[ "$1" == "-f" ]]; then
    # 从文件读取
    local file="$2"
    if [[ -z "$file" ]]; then
      error "必须指定文件路径"
      return 1
    fi

    local file_users
    if file_users=$(read_users_from_file "$file"); then
      read -ra users <<<"$file_users"
    else
      return 1
    fi
  else
    # 从命令行参数读取
    users=("$@")
  fi

  if [[ ${#users[@]} -eq 0 ]]; then
    error "必须指定要同步的用户列表"
    echo "使用 sync user1 user2... 或 sync -f filename"
    return 1
  fi

  log "🔄 开始同步 SSH keys (SSH用户: $SSH_USER)"

  # 显示将要同步的用户
  echo "准备同步的用户:"
  printf "  - %s\n" "${users[@]}"
  echo ""

  # 创建备份
  create_backup

  # 移除所有团队成员的旧 keys（保留其他 keys）
  if [[ -f "$AUTHORIZED_KEYS" ]]; then
    sed -i '/team-/d' "$AUTHORIZED_KEYS"
  else
    touch "$AUTHORIZED_KEYS"
  fi

  # 统计变量
  local success_count=0
  local fail_count=0

  # 重新添加所有用户
  for github_user in "${users[@]}"; do
    if ! validate_github_user "$github_user"; then
      warn "跳过无效用户名: $github_user"
      ((fail_count++))
      continue
    fi

    echo "正在同步 $github_user..."

    local keys
    if keys=$(get_github_keys "$github_user"); then
      if [[ -n "$keys" ]]; then
        local key_count=0
        while IFS= read -r key; do
          if [[ -n "$key" && ! "$key" =~ ^# ]]; then
            echo "$key team-$github_user-$(date +%Y%m%d)" >>"$AUTHORIZED_KEYS"
            ((key_count++))
          fi
        done <<<"$keys"

        echo "  ✅ $github_user - 已同步 ($key_count 个 keys)"
        ((success_count++))
      else
        warn "  $github_user - 未找到 SSH keys"
        ((fail_count++))
      fi
    else
      error "  $github_user - 获取失败"
      ((fail_count++))
    fi
  done

  # 设置正确的权限
  fix_permissions

  # 显示结果
  echo ""
  log "✅ 同步完成"
  echo "📊 同步结果: 成功 $success_count, 失败 $fail_count"
  echo ""
  echo "📋 当前团队成员:"
  list_users
}

# 手动备份
manual_backup() {
  log "创建手动备份..."

  if create_backup; then
    log "✅ 手动备份完成"
  else
    error "备份失败"
    return 1
  fi
}

# 从备份恢复
restore_from_backup() {
  echo "=== 可用的备份文件 ==="
  local backups
  backups=$(ls -t "${AUTHORIZED_KEYS}".backup.* 2>/dev/null)

  if [[ -z "$backups" ]]; then
    error "未找到备份文件"
    return 1
  fi

  echo "$backups" | nl
  echo ""

  read -p "请输入要恢复的备份文件编号 (或完整路径): " choice

  local backup_file
  if [[ "$choice" =~ ^[0-9]+$ ]]; then
    backup_file=$(echo "$backups" | sed -n "${choice}p")
  else
    backup_file="$choice"
  fi

  if [[ -f "$backup_file" ]]; then
    log "从 $backup_file 恢复..."
    cp "$backup_file" "$AUTHORIZED_KEYS"
    fix_permissions
    log "✅ 恢复完成"
  else
    error "备份文件不存在: $backup_file"
    return 1
  fi
}

# 主函数
main() {
  # 解析参数
  parse_args "$@"

  # 检查权限
  check_permissions

  # 执行命令
  case "$COMMAND" in
    add)
      if [[ ${#ARGS[@]} -ne 1 ]]; then
        error "add 命令需要一个 GitHub 用户名"
        exit 1
      fi
      add_user "${ARGS[0]}"
      ;;
    remove)
      if [[ ${#ARGS[@]} -ne 1 ]]; then
        error "remove 命令需要一个 GitHub 用户名"
        exit 1
      fi
      remove_user "${ARGS[0]}"
      ;;
    list)
      list_users
      ;;
    sync)
      if [[ ${#ARGS[@]} -eq 0 ]]; then
        error "sync 命令需要用户列表或 -f 文件参数"
        exit 1
      fi
      sync_users "${ARGS[@]}"
      ;;
    status)
      show_status
      ;;
    backup)
      manual_backup
      ;;
    restore)
      restore_from_backup
      ;;
    "")
      error "未指定命令"
      usage
      ;;
    *)
      error "未知命令: $COMMAND"
      usage
      ;;
  esac
}

# 执行主函数
main "$@"
