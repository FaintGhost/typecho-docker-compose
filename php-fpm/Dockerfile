
# 为typecho构建的php-fpm镜像，因为官方的php镜像没有启动pod_mysql扩展，因此需要自行构建一个
FROM php:fpm
# 安装pdo_mysql拓展
RUN apt-get update && docker-php-ext-install pdo_mysql
