# 多阶段:node 构建 → nginx 托管静态产物(照 shabox-blog-web 模式)
FROM node:22-alpine AS builder
WORKDIR /app
# corepack 拉 pnpm 与依赖都走 npmmirror
ENV COREPACK_NPM_REGISTRY=https://registry.npmmirror.com
RUN corepack enable && pnpm config set registry https://registry.npmmirror.com && pnpm config set fetch-retries 5
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN --mount=type=cache,id=aurya-pnpm-store,target=/root/.local/share/pnpm/store pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx-conf/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
