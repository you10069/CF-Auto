# 使用官方Python镜像作为基础镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    TZ=Asia/Shanghai \
    LANG=C.UTF-8

# 安装系统依赖（包括cron用于定时任务）
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    ca-certificates \
    tzdata \
    cron \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY cloudflare_speedtest.py .

COPY CloudflareST_proxy_linux_amd64 /app/CloudflareST_proxy_linux_amd64
COPY CloudflareST_proxy_linux_arm64 /app/CloudflareST_proxy_linux_arm64

# 赋予可执行文件执行权限
RUN chmod +x /app/CloudflareST_proxy_linux_amd64 \
    && chmod +x /app/CloudflareST_proxy_linux_arm64

# 创建数据目录（用于保存结果文件）
RUN mkdir -p /app/data /app/config

# 复制启动脚本
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# 设置入口点
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# 默认命令（保持容器运行）
CMD []

