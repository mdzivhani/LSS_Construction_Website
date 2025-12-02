#!/bin/bash
# SSL Certificate Setup for leetshego.co.za
# Run this script once DNS has fully propagated

echo "Checking DNS propagation..."
DNS_CHECK=$(dig +short leetshego.co.za @8.8.8.8)

if [ -z "$DNS_CHECK" ]; then
    echo "❌ DNS not propagated yet. Please wait and try again."
    echo "Expected IP: 102.214.11.174"
    exit 1
fi

echo "✅ DNS resolved to: $DNS_CHECK"
echo ""
echo "Stopping system nginx..."
sudo systemctl stop nginx

echo ""
echo "Obtaining SSL certificate..."
sudo certbot certonly --standalone \
    -d leetshego.co.za \
    -d www.leetshego.co.za \
    --email Leetshego@gmail.com \
    --agree-tos \
    --no-eff-email

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SSL certificate obtained successfully!"
    echo ""
    echo "Updating Nginx configuration for HTTPS..."
    
    # Backup HTTP-only config
     # Create/replace system nginx site config
     sudo tee /etc/nginx/sites-available/leetshego.co.za.conf > /dev/null << 'EOF'
# HTTP server - redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name leetshego.co.za www.leetshego.co.za;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS server - proxy to leetshego-nginx container
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name leetshego.co.za www.leetshego.co.za;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/leetshego.co.za/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/leetshego.co.za/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy to leetshego-nginx container
    location / {
        proxy_pass http://leetshego-nginx:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }
}
EOF
    
    echo ""
    echo "Starting system nginx with HTTPS..."
    sudo nginx -t && sudo systemctl start nginx && sudo systemctl enable nginx
    
    echo ""
    echo "✅ Setup complete! Testing HTTPS..."
    sleep 2
    curl -I https://leetshego.co.za
    
else
    echo ""
    echo "❌ SSL certificate acquisition failed."
    echo "Restarting system nginx..."
    sudo systemctl start nginx
    exit 1
fi
