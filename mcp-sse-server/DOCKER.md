# 🐳 Docker 使用指南

本指南將幫助您使用 Docker 來運行 MCP SSE 服務器。

## 快速開始

### 1. 使用 Docker Compose（推薦）

```bash
# 啟動服務
npm run docker:up

# 查看日志
npm run docker:logs

# 停止服務
npm run docker:down
```

### 2. 使用 Docker 命令

```bash
# 構建映像
npm run docker:build

# 運行容器
npm run docker:run

# 測試 Docker 構建
npm run docker:test
```

## 詳細說明

### 環境變量

可以通過以下環境變量配置服務器：

| 變量名稱 | 默認值 | 說明 |
|---------|-------|------|
| `PORT` | `8083` | 服務器端口 |
| `NODE_ENV` | `production` | 運行環境 |
| `LOG_LEVEL` | `info` | 日志級別 |
| `HEARTBEAT_INTERVAL` | `30000` | 心跳間隔（毫秒）|
| `ALLOWED_ORIGINS` | `*` | 允許的 CORS 來源 |

### 使用自定義環境變量

創建 `.env` 文件：

```bash
PORT=8083
NODE_ENV=production
LOG_LEVEL=debug
HEARTBEAT_INTERVAL=30000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

然後在 `docker-compose.yml` 中使用：

```yaml
services:
  mcp-sse-server:
    env_file:
      - .env
```

### 端口映射

默認情況下，服務器在端口 8083 上運行。您可以通過以下方式修改：

```bash
# 映射到不同的主機端口
docker run -p 3000:8083 mcp-sse-server

# 或者修改容器內部端口
docker run -p 8083:8083 -e PORT=8083 mcp-sse-server
```

### 持久化數據

如果需要持久化日志或其他數據，可以使用 Docker 卷：

```yaml
volumes:
  - ./logs:/app/logs
  - ./data:/app/data
```

### 健康檢查

容器包含內建的健康檢查：

```bash
# 檢查容器狀態
docker ps

# 手動健康檢查
curl http://localhost:8083/health
```

健康檢查端點返回：

```json
{
  "status": "ok",
  "version": "1.0.0",
  "uptime": 123.45,
  "timestamp": "2025-01-XX:XX:XX.XXXZ",
  "connections": 2
}
```

### 多階段構建

Dockerfile 使用多階段構建來優化映像大小：

1. **構建階段**：安裝依賴並構建 TypeScript
2. **運行階段**：只包含生產依賴和構建產物

### 安全性

- 使用非 root 用戶運行（nodejs:1001）
- 基於 Alpine Linux 減少攻擊面
- 只暴露必要的端口
- 支持 CORS 配置

### 故障排除

#### 常見問題

1. **端口衝突**
   ```bash
   # 檢查端口使用情況
   netstat -an | grep 8083
   
   # 使用不同端口
   docker run -p 8084:8083 mcp-sse-server
   ```

2. **構建失敗**
   ```bash
   # 查看詳細構建日志
   docker build --no-cache -t mcp-sse-server .
   
   # 檢查 TypeScript 編譯
   npm run build
   ```

3. **容器無法啟動**
   ```bash
   # 查看容器日志
   docker logs <container_id>
   
   # 進入容器調試
   docker exec -it <container_id> /bin/sh
   ```

4. **健康檢查失敗**
   ```bash
   # 檢查容器內部網絡
   docker exec -it <container_id> curl localhost:8083/health
   
   # 檢查防火牆設置
   ```

#### 日志調試

```bash
# 實時查看日志
docker logs -f mcp-sse-server

# 查看特定時間段的日志
docker logs --since="2025-01-01T00:00:00" mcp-sse-server
```

### 生產環境部署

#### 資源限制

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

#### 反向代理

使用 Nginx 作為反向代理：

```nginx
upstream mcp-sse {
    server localhost:8083;
}

server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://mcp-sse;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # SSE 特定配置
        proxy_buffering off;
        proxy_cache off;
        proxy_set_header Connection '';
        chunked_transfer_encoding off;
    }
}
```

#### 監控和日志

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 開發環境

對於開發環境，可以使用卷掛載來實現熱重載：

```yaml
volumes:
  - ./src:/app/src
  - ./package.json:/app/package.json
command: npm run dev
```

### 測試

運行自動化測試：

```bash
# 運行 Docker 測試腳本
npm run docker:test

# 或者手動測試
docker build -t mcp-sse-server-test .
docker run -d -p 8083:8083 --name test-container mcp-sse-server-test
curl http://localhost:8083/health
docker stop test-container && docker rm test-container
``` 