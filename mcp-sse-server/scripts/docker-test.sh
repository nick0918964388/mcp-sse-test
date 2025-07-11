#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函數定義
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查 Docker 是否安裝
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安裝或未在 PATH 中"
    exit 1
fi

# 檢查 Docker 是否運行
if ! docker info &> /dev/null; then
    log_error "Docker 未運行"
    exit 1
fi

log_info "開始構建 Docker 映像..."

# 構建 Docker 映像
if docker build -t mcp-sse-server-test .; then
    log_info "Docker 映像構建成功"
else
    log_error "Docker 映像構建失敗"
    exit 1
fi

log_info "啟動測試容器..."

# 運行容器（後台）
CONTAINER_ID=$(docker run -d -p 8083:8083 --name mcp-sse-server-test mcp-sse-server-test)

if [ $? -eq 0 ]; then
    log_info "測試容器已啟動，容器 ID: $CONTAINER_ID"
else
    log_error "容器啟動失敗"
    exit 1
fi

# 等待服務啟動
log_info "等待服務啟動..."
sleep 5

# 檢查健康狀態
log_info "檢查健康狀態..."
if curl -f http://localhost:8083/health &> /dev/null; then
    log_info "健康檢查通過"
else
    log_warn "健康檢查失敗，檢查容器日志..."
    docker logs mcp-sse-server-test
fi

# 清理
log_info "清理測試容器..."
docker stop mcp-sse-server-test &> /dev/null
docker rm mcp-sse-server-test &> /dev/null
docker rmi mcp-sse-server-test &> /dev/null

log_info "測試完成" 