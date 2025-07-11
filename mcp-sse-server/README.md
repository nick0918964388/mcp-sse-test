# SSE 类型的 MCP 服务器

基于 TypeScript 实现的 MCP (模型上下文协议) SSE 服务器，提供智能商城相关功能，用于连接 Claude 等大型语言模型和微服务 API。

## 功能特点

- 使用 SSE (Server-Sent Events) 实现实时数据推送
- 支持多客户端同时连接
- 提供商品查询、库存管理和订单处理的 MCP 工具
- 与 Claude API 无缝集成
- 包含健康检查和心跳机制
- 实现优雅关闭和错误处理

## 项目结构

```
mcp-sse-server/
├── src/
│   ├── types/            # 类型定义
│   ├── services/         # 微服务 API 实现
│   │   ├── products.ts   # 商品服务
│   │   ├── inventory.ts  # 库存服务
│   │   └── orders.ts     # 订单服务
│   ├── mcp-server.ts     # MCP 服务器实现
│   ├── mcp-sse-server.ts # SSE 传输层实现
│   ├── index.ts          # 入口文件
│   └── config.ts         # 配置文件
├── package.json
└── tsconfig.json
```

## 安装与运行

1. 安装依赖

```bash
npm install
```

2. 创建环境配置文件

```bash
cp .env.example .env
```

3. 启动开发服务器

```bash
npm run dev
```

4. 构建生产版本

```bash
npm run build
```

5. 启动生产服务器

```bash
npm start
```

## API 端点

- **SSE 连接**: `GET /sse`

  - 建立 SSE 连接，获取实时更新

- **消息处理**: `POST /messages`

  - 接收 MCP 客户端消息并处理

- **健康检查**: `GET /health`
  - 获取服务器状态信息

## MCP 工具说明

本服务器实现了一个智能商城系统，提供以下 MCP 工具：

1. **getProducts**: 获取所有产品信息

   - 参数: 无
   - 返回: 产品列表，包含 id、name、price、description 等信息

2. **getInventory**: 获取所有产品的库存信息

   - 参数: 无
   - 返回: 库存信息列表，包含 productId、quantity 等信息

3. **getOrders**: 获取所有订单信息

   - 参数: 无
   - 返回: 订单列表，包含 id、customerName、items、totalAmount 等信息

4. **purchase**: 购买商品
   - 参数:
     - customerName: 客户姓名
     - items: 商品列表，每项包含 productId 和 quantity
   - 返回: 订单信息

## 与 Claude 集成

该服务器专为与 Claude 等大型语言模型集成而设计，使用 MCP 协议实现工具调用。集成步骤：

1. 启动 MCP SSE 服务器
2. 使用 MCP 客户端连接到服务器获取工具列表
3. 将工具信息传递给 Claude API
4. Claude 可以根据用户需求调用相应的工具
5. 客户端处理工具结果并返回给用户

## 生产环境部署

部署到生产环境时，请考虑以下最佳实践：

1. 使用进程管理器如 PM2 管理 Node.js 进程
2. 设置合适的内存限制
3. 配置负载均衡以实现高可用性
4. 启用 HTTPS 以确保通信安全
5. 设置适当的日志级别和监控工具

## 🐳 Docker 容器化部署

### 環境變量設定

在運行 Docker 容器之前，您可以設定以下環境變量：

```bash
# 服務器端口
PORT=8083

# 日志級別
LOG_LEVEL=info

# 心跳間隔 (毫秒)
HEARTBEAT_INTERVAL=30000

# 允許的來源 (多個用逗號分隔)
ALLOWED_ORIGINS=*

# 生產環境設定
NODE_ENV=production
```

### 使用 Docker 構建和運行

#### 方法 1: 使用 Docker 命令

```bash
# 構建 Docker 映像
npm run docker:build

# 運行容器
npm run docker:run

# 或者直接使用 docker 命令
docker build -t mcp-sse-server .
docker run -p 8083:8083 --name mcp-sse-server mcp-sse-server
```

#### 方法 2: 使用 Docker Compose（推薦）

```bash
# 啟動服務（後台運行）
npm run docker:up

# 查看日志
npm run docker:logs

# 停止服務
npm run docker:down
```

### Docker 映像特性

- 基於 `node:18-alpine` 輕量級基礎映像
- 非 root 用戶運行，增強安全性
- 內建健康檢查機制
- 支持優雅關閉
- 生產環境優化

### 健康檢查

容器包含內建的健康檢查功能：

```bash
# 檢查容器健康狀態
docker ps

# 手動健康檢查
curl -f http://localhost:8083/health
```

### 端口映射

- 容器內部端口：8083
- 映射到主機端口：8083
- 可以通過環境變量 `PORT` 自定義

### 生產環境部署建議

1. **使用 Docker Compose**：便於管理多容器應用
2. **設置資源限制**：
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '0.5'
         memory: 512M
   ```
3. **配置日志輪轉**：避免日志文件過大
4. **使用 Docker Secrets**：管理敏感信息
5. **配置反向代理**：如 Nginx 或 Traefik

## SSE (Server-Sent Events) 说明

SSE 是一种服务器推送技术，允许服务器向客户端发送事件流。与 WebSocket 不同，SSE 是单向的（只从服务器到客户端），并使用标准 HTTP 协议。

SSE 特性：

- 基于 HTTP，无需特殊协议
- 自动重连机制
- 事件 ID 和自定义事件类型
- 相比 WebSocket 更轻量级

在 MCP 服务器中，SSE 用于：

1. 将工具定义发送给 MCP 客户端
2. 在工具调用完成后发送结果
3. 发送心跳以保持连接活跃

## 示例客户端

我们提供了两种客户端实现：

1. 命令行客户端 (CLI)
2. Web 客户端

相关代码和使用方法请参考 [MCP 客户端示例](../mcp-client/README.md)。

![智能商城 Web 界面](https://picdn.youdianzhishi.com/images/1743580945607.png)
