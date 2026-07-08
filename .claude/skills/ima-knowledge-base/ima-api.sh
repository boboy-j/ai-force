#!/usr/bin/env bash
# IMA Knowledge Base API 封装
# 使用前确保 ~/.config/ima/client_id 和 ~/.config/ima/api_key 已配置

set -euo pipefail

CONFIG_DIR="$HOME/.config/ima"
CLIENT_ID_FILE="$CONFIG_DIR/client_id"
API_KEY_FILE="$CONFIG_DIR/api_key"

if [ ! -f "$CLIENT_ID_FILE" ] || [ ! -f "$API_KEY_FILE" ]; then
  echo "错误: 未找到IMA凭证文件。请确保 ~/.config/ima/client_id 和 ~/.config/ima/api_key 已配置。"
  exit 1
fi

CLIENT_ID=$(cat "$CLIENT_ID_FILE")
API_KEY=$(cat "$API_KEY_FILE")

KB_BASE_URL="https://ima.qq.com/openapi/wiki/v1"
NOTE_BASE_URL="https://ima.qq.com/openapi/note/v1"

AUTH_HEADERS=(-H "ima-openapi-clientid: $CLIENT_ID" -H "ima-openapi-apikey: $API_KEY" -H "Content-Type: application/json")

function list_knowledge_bases() {
  curl -s "${AUTH_HEADERS[@]}" "$KB_BASE_URL/knowledge-bases" | jq '.'
}

function search_knowledge_base() {
  local kb_id="$1"
  local query="$2"
  local body=$(jq -n --arg q "$query" '{query: $q}')
  curl -s "${AUTH_HEADERS[@]}" -X POST -d "$body" "$KB_BASE_URL/knowledge-bases/$kb_id/search" | jq '.'
}

function list_folders() {
  local kb_id="$1"
  curl -s "${AUTH_HEADERS[@]}" "$KB_BASE_URL/knowledge-bases/$kb_id/folders" | jq '.'
}

function get_document() {
  local kb_id="$1"
  local doc_id="$2"
  curl -s "${AUTH_HEADERS[@]}" "$KB_BASE_URL/knowledge-bases/$kb_id/documents/$doc_id" | jq '.'
}

function upload_document() {
  local kb_id="$1"
  local file_path="$2"
  local folder_id="${3:-}"

  # Step 1: 获取临时上传凭证
  local creds=$(curl -s "${AUTH_HEADERS[@]}" "$KB_BASE_URL/knowledge-bases/$kb_id/upload-credentials" | jq '.')
  echo "上传凭证: $creds" >&2

  # Step 2: 上传到COS
  local bucket=$(echo "$creds" | jq -r '.bucket // .data.bucket // empty')
  local region=$(echo "$creds" | jq -r '.region // .data.region // empty')
  local tmp_secret_id=$(echo "$creds" | jq -r '.secretId // .data.credentials?.tmpSecretId // empty')
  local tmp_secret_key=$(echo "$creds" | jq -r '.secretKey // .data.credentials?.tmpSecretKey // empty')
  local session_token=$(echo "$creds" | jq -r '.sessionToken // .data.credentials?.sessionToken // empty')
  local cos_key=$(echo "$creds" | jq -r '.cosKey // .data.cosKey // empty')

  if [ -z "$bucket" ] || [ -z "$region" ] || [ -z "$tmp_secret_id" ]; then
    echo "错误: 无法获取上传凭证" >&2
    echo "$creds"
    exit 1
  fi

  echo "使用COS上传: bucket=$bucket, region=$region" >&2

  # 使用COS上传工具或直接PUT
  local file_name=$(basename "$file_path")
  local encoded_key=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$cos_key', safe=''))")
  local cos_url="https://${bucket}.cos.${region}.myqcloud.com/${encoded_key}"

  # Step 3: 通知IMA上传完成
  local notify_body=$(jq -n \
    --arg key "$cos_key" \
    --arg name "$file_name" \
    --arg folder "$folder_id" \
    '{cosKey: $key, fileName: $name, folderId: $folder}')

  curl -s "${AUTH_HEADERS[@]}" -X POST -d "$notify_body" \
    "$KB_BASE_URL/knowledge-bases/$kb_id/documents" | jq '.'
}

function import_url() {
  local kb_id="$1"
  local url="$2"
  local folder_id="${3:-}"
  local body=$(jq -n \
    --arg u "$url" \
    --arg f "$folder_id" \
    '{url: $u, folderId: $f}')
  curl -s "${AUTH_HEADERS[@]}" -X POST -d "$body" \
    "$KB_BASE_URL/knowledge-bases/$kb_id/documents/import-url" | jq '.'
}

# Main command dispatch
case "${1:-help}" in
  list|ls)
    list_knowledge_bases
    ;;
  search|s)
    if [ $# -lt 3 ]; then
      echo "用法: $0 search <知识库ID> <查询词>"
      exit 1
    fi
    search_knowledge_base "$2" "$3"
    ;;
  folders|f)
    if [ $# -lt 2 ]; then
      echo "用法: $0 folders <知识库ID>"
      exit 1
    fi
    list_folders "$2"
    ;;
  get|g)
    if [ $# -lt 3 ]; then
      echo "用法: $0 get <知识库ID> <文档ID>"
      exit 1
    fi
    get_document "$2" "$3"
    ;;
  upload|u)
    if [ $# -lt 3 ]; then
      echo "用法: $0 upload <知识库ID> <文件路径> [文件夹ID]"
      exit 1
    fi
    upload_document "$2" "$3" "${4:-}"
    ;;
  import-url|iu)
    if [ $# -lt 3 ]; then
      echo "用法: $0 import-url <知识库ID> <URL> [文件夹ID]"
      exit 1
    fi
    import_url "$2" "$3" "${4:-}"
    ;;
  test)
    echo "测试IMA API连接..."
    local result=$(list_knowledge_bases)
    echo "$result" | jq '.'
    ;;
  *)
    echo "IMA知识库工具"
    echo "用法: $0 <command> [args]"
    echo ""
    echo "命令:"
    echo "  list                   列出所有知识库"
    echo "  search <kb_id> <query> 搜索知识库"
    echo "  folders <kb_id>        列出知识库文件夹"
    echo "  get <kb_id> <doc_id>   获取文档内容"
    echo "  upload <kb_id> <path>  上传文件 [folder_id]"
    echo "  import-url <kb_id> <url> 导入URL [folder_id]"
    echo "  test                   测试API连接"
    ;;
esac