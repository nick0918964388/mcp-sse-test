# 使用官方 Node.js 18 Alpine 映像作為基礎
FROM node:18-alpine

# 設定工作目錄
WORKDIR /app

# 複製 package.json 和 package-lock.json
COPY package*.json ./

# 安裝依賴
RUN npm ci --only=production

# 複製源代碼
COPY . .

# 構建 TypeScript 項目
RUN npm run build

# 複製並設置入口腳本權限
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 創建非 root 用戶以提高安全性
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# 更改文件所有權
RUN chown -R nodejs:nodejs /app
USER nodejs

# 暴露端口
EXPOSE 8083

# 設定環境變量
ENV NODE_ENV=production
ENV PORT=8083

# 健康檢查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8083/health || exit 1

# 設置入口點
ENTRYPOINT ["docker-entrypoint.sh"]

# 啟動命令
CMD ["npm", "start"] 