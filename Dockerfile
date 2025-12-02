FROM nginx:stable-alpine

# Copy website files
COPY . /usr/share/nginx/html

# Copy custom nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d /etc/nginx/conf.d

# Container listens on standard HTTP/HTTPS internally; host maps 9080/9443
EXPOSE 80 443

# Remove default.conf to avoid conflicting server_name localhost
RUN rm -f /etc/nginx/conf.d/default.conf || true

CMD ["nginx", "-g", "daemon off;"]
