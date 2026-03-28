FROM nginx:alpine
# 只拷贝配置文件，不拷贝 map_data（因为 map_data 以后从 NAS 挂载）
COPY ./nginx.conf /etc/nginx/conf.d/default.conf