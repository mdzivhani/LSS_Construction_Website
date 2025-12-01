# LSS Construction Website - Instructions

This directory contains all operational documentation and guidelines for the Leetshego Safety Solutions website.

## Documentation Index

### Deployment & Operations
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Complete deployment guide, SSL setup, and troubleshooting
- **[setup-ssl.sh](./setup-ssl.sh)** - Automated SSL certificate setup script

### Content Management
- **[content-management.md](./content-management.md)** - Guide for updating website content, images, and pages

### Project Information
- **Project Name:** Leetshego Safety Solutions Website
- **Domain:** leetshego.co.za
- **Technology:** Static HTML/CSS/JS with Bootstrap 5
- **Container:** Nginx (Alpine)
- **Logs Location:** `/home/mulalo/logs/lss_construction/`

## Quick Reference

### Start/Stop Services
```bash
cd /home/mulalo/applications/lss_construction

# Start
docker compose up -d

# Stop
docker compose stop

# Restart
docker compose restart

# Rebuild after changes
docker compose up -d --build
```

### View Logs
```bash
# Container logs
docker logs leetshego-nginx

# Nginx access logs
tail -f /home/mulalo/logs/lss_construction/access.log

# Nginx error logs
tail -f /home/mulalo/logs/lss_construction/error.log
```

### SSL Certificate
```bash
# Enable HTTPS (after DNS propagation)
cd /home/mulalo/applications/lss_construction/instructions
./setup-ssl.sh

# Check certificate expiry
sudo certbot certificates

# Renew certificate
sudo certbot renew
```

### Update Content
1. Edit HTML/CSS/JS files in `/home/mulalo/applications/lss_construction/`
2. Rebuild container: `docker compose up -d --build`
3. Clear browser cache to see changes

## File Structure

```
/home/mulalo/applications/lss_construction/
├── instructions/          # This directory
│   ├── README.md         # This file
│   ├── DEPLOYMENT.md     # Deployment guide
│   └── setup-ssl.sh      # SSL setup script
├── nginx/                # Nginx configuration
│   ├── nginx.conf
│   └── conf.d/
├── assets/               # Static assets
│   ├── css/
│   ├── js/
│   ├── img/
│   └── vendor/
├── *.html                # Website pages
├── Dockerfile
└── docker-compose.yml
```

## Logs Location

All Nginx logs are stored in `/home/mulalo/logs/lss_construction/`:
- `access.log` - HTTP access logs
- `error.log` - Nginx error logs

## Contact & Support

**Site Contact Information:**
- Email: Leetshego@gmail.com
- Phone: 078 287 9661 / 067 774 6135
- WhatsApp: https://wa.me/27782879661
- Address: 02 Kelly Road, Jet Park, Boksburg, South Africa

**Technical Details:**
- Repository: LSS_Construction_Website
- Server: 102.214.11.174
- Nameservers: ns1-4.mydnscloud.com