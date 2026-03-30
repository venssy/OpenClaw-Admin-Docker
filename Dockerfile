# 第一阶段：编译构建
FROM node:22-alpine AS builder
WORKDIR /app
COPY . .
# 根据 README 推测的标准构建流程
RUN npm install && npm run build

# 第二阶段：生产环境（保持镜像极小）
FROM nginx:alpine
# 将构建产物拷贝到 Nginx 默认目录
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
