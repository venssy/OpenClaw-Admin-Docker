# 阶段 1: 构建环境
FROM node:22-slim AS builder

# 安装 Python 及构建工具（如 node-gyp 依赖）
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN sed -i '/const _rpcMethodWhitelist = new Set/a    "cron.list", "models.list", "skills.status", "usage.cost", "sessions.usage", ' server/index.js

# 执行构建逻辑
RUN npm install
RUN npm run build

# 阶段 2: 运行环境
FROM node:22-slim
WORKDIR /app
# 仅从构建阶段拷贝产物，保持镜像精简
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/data ./data
COPY --from=builder /app/server ./server
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.env.example ./.env

EXPOSE 3000
CMD ["npm", "run", "preview"]
