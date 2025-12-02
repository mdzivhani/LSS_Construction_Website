# Static Site Content & Asset Handling

This repository hosts a standalone static site (HTML/CSS/JS) with no shared services, no external application database, and no cross-application dependencies.

## Scope
Only static files under `assets/` plus nginx configuration are deployed. No user data persistence layer exists.

## Backups
Use git for version history. Optional image archive:
```bash
docker save -o leetshego_site_$(date +%Y%m%d).tar lss_construction-nginx:latest
```

## SSL
Managed by system nginx + Let's Encrypt. Renew:
```bash
sudo certbot renew && sudo systemctl restart nginx
```

## Health
HTTP: `curl -I http://127.0.0.1:9080/health`
HTTPS: `curl -I https://127.0.0.1:9443/health`

## Deploy Updated Content
```bash
cd /home/mulalo/applications/lss_construction
docker compose up -d --build
```

## Last Updated
December 2, 2025
