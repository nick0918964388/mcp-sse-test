#!/bin/sh

# 確保 dist 目錄存在
if [ ! -d "dist" ]; then
    echo "错误：dist 目录不存在，请确保已经构建了项目"
    exit 1
fi

# 檢查主要文件是否存在
if [ ! -f "dist/mcp-sse-server.js" ]; then
    echo "错误：找不到 mcp-sse-server.js 文件"
    exit 1
fi

# 顯示啟動信息
echo "正在启动 MCP SSE 服务器..."
echo "端口: ${PORT:-8083}"
echo "环境: ${NODE_ENV:-production}"

# 啟動應用
exec "$@" 