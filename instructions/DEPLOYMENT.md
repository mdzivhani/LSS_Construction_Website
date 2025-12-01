# LSS Construction Website - Deployment Guide

## Current Status

✅ **Deployed and Running**
- Container: `leetshego-nginx` (lss_construction-nginx:latest)
- Ports: 8080 (HTTP), 8443 (HTTPS ready)
- Network: Connected to `lss_construction_leetshego-network` and `ndlela-search-engine_ndlela-network`
- Proxy: Main Nginx routes leetshego.co.za → leetshego-nginx container

✅ **DNS Configuration**
- Domain: leetshego.co.za
- Subdomain: www.leetshego.co.za
- IP: 102.214.11.174
- Nameservers: ns1-4.mydnscloud.com
- Status: Configured in DNS panel, propagation in progress

⏳ **SSL Certificate**
- Status: Pending DNS propagation
- Certificate Authority: Let's Encrypt
- Email: Leetshego@gmail.com
- Script: `setup-ssl.sh` ready to run

## Architecture

```
Internet (port 80/443)
    ↓
ndlela-nginx (main reverse proxy)
    ↓
leetshego-nginx (static site container)
    ↓
Static HTML/CSS/JS files
```

## Access

- **HTTP (Current):** http://leetshego.co.za (via main Nginx proxy)
- **Local Test:** http://localhost:8080 (direct to container)
- **HTTPS:** Will be available after SSL setup

## SSL Certificate Setup

Once DNS has fully propagated (typically 5-30 minutes), run:

```bash
cd /home/mulalo/applications/lss_construction
./setup-ssl.sh
```

The script will:
1. Check DNS propagation
2. Stop main Nginx temporarily
3. Obtain Let's Encrypt certificate for leetshego.co.za and www
4. Update Nginx config with HTTPS and redirect
5. Restart Nginx with SSL enabled

## Manual SSL Setup (Alternative)

If you prefer to do it manually:

```bash
# 1. Check DNS
dig +short leetshego.co.za @8.8.8.8
# Should return: 102.214.11.174

# 2. Stop main Nginx
cd /home/mulalo/applications/ndlela-search-engine
docker compose -f docker-compose.prod.yml stop nginx

# 3. Get certificate
sudo certbot certonly --standalone \
    -d leetshego.co.za \
    -d www.leetshego.co.za \
    --email Leetshego@gmail.com \
    --agree-tos --no-eff-email

# 4. Update Nginx config
# Replace /home/mulalo/applications/ndlela-search-engine/nginx/conf.d/leetshego.conf
# with HTTPS configuration (see setup-ssl.sh for template)

# 5. Start Nginx
docker compose -f docker-compose.prod.yml start nginx

# 6. Test
curl -I https://leetshego.co.za
```

## File Structure

```
/home/mulalo/applications/lss_construction/
├── index.html, about.html, services.html, etc.
├── assets/
│   ├── css/
│   ├── js/
│   ├── img/
│   └── vendor/
├── Dockerfile
├── docker-compose.yml
├── nginx/
│   ├── nginx.conf
│   └── conf.d/
│       └── leetshego-http.conf
├── setup-ssl.sh
└── DEPLOYMENT.md (this file)
```

## Container Management

```bash
# View logs
docker logs leetshego-nginx

# Restart container
cd /home/mulalo/applications/lss_construction
docker compose restart

# Rebuild and restart (after code changes)
docker compose up -d --build

# Stop
docker compose stop

# Remove
docker compose down
```

## Updating Content

1. Edit HTML/CSS/JS files in `/home/mulalo/applications/lss_construction/`
2. Rebuild container:
   ```bash
   cd /home/mulalo/applications/lss_construction
   docker compose up -d --build
   ```

## SSL Certificate Renewal

Certificates expire after 90 days. Renew with:

```bash
sudo certbot renew
docker compose -f /home/mulalo/applications/ndlela-search-engine/docker-compose.prod.yml restart nginx
```

Consider setting up auto-renewal with cron:
```bash
sudo crontab -e
# Add: 0 0 1 * * certbot renew --quiet && docker restart ndlela-nginx
```

## Troubleshooting

### DNS not resolving
- Check authoritative NS: `dig @ns1.mydnscloud.com leetshego.co.za`
- Wait 5-30 minutes for global propagation
- Verify DNS panel shows correct A records

### Can't obtain SSL certificate
- Ensure DNS resolves to 102.214.11.174
- Check port 80 is accessible: `curl -I http://leetshego.co.za`
- Verify no other service is using port 80

### Site not accessible via domain
- Check main Nginx: `docker logs ndlela-nginx`
- Verify network connection: `docker network inspect ndlela-search-engine_ndlela-network`
- Test container directly: `curl http://localhost:8080`

### Container won't start
- Check logs: `docker logs leetshego-nginx`
- Verify Nginx config: `docker exec leetshego-nginx nginx -t`

## Contact Information

Site displays:
- Email: Leetshego@gmail.com
- Phone: 078 287 9661 / 067 774 6135
- WhatsApp: https://wa.me/27782879661
- Address: 02 Kelly Road, Jet Park, Boksburg, South Africa

## Next Steps

1. ✅ Wait for DNS propagation (5-30 minutes)
2. ⏳ Run `./setup-ssl.sh` to enable HTTPS
3. ⏳ Test site at https://leetshego.co.za
4. ⏳ Update content with real LSS images and case studies
5. ⏳ Consider analytics integration (Google Analytics)
6. ⏳ Set up automated backups
7. ⏳ Configure email for contact forms (forms/contact.php needs backend)
