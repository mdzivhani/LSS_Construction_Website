# Application Isolation Guidelines

## Critical Development Requirement

**All applications on this server MUST remain fully isolated from each other.**

## Mandatory Isolation Rules

### 1. No Shared Configurations
- Each application must have its own configuration files
- No shared nginx configs, docker-compose files, or environment configurations
- Configuration changes in one application must NEVER affect another application

### 2. No Shared Services
- Each application must run its own instances of all required services
- No shared databases, caches, message queues, or backend services
- Each application has complete independence in service management

### 3. No Shared Containers
- Each application must have its own Docker containers
- Container names must be unique and application-specific
- No container should serve multiple applications

### 4. No Shared Ports
- Each application must use distinct, non-overlapping port ranges
- Internal and external ports must never conflict
- Port mappings must be documented and maintained

### 5. No Shared Environment Variables
- Each application manages its own environment variables
- No global or shared .env files across applications
- Secrets and credentials must be application-specific

### 6. No Shared Dependencies
- Each application builds and manages its own dependencies
- No shared package directories or dependency caches
- Version conflicts must be impossible between applications

### 7. Independent Lifecycle
- **Restarting one application must NEVER affect other applications**
- **Updating one application must NEVER impact other applications**
- **Failures in one application must remain contained and isolated**

## Application-Specific Information

**Application Name:** Leetshego Safety Solutions

**Location:** `/home/mulalo/applications/lss_construction`

**Docker Network:** `leetshego-network` (isolated)

**Ports:**
- 8080 (HTTP)
- 8443 (HTTPS)

**Containers:**
- `leetshego-nginx` - Nginx static server

**Volumes:**
- `/home/mulalo/logs/lss_construction` - Application logs
- `/etc/letsencrypt` - SSL certificates (read-only, shared at OS level only)

**Configuration Files:**
- `docker-compose.yml`
- `Dockerfile`
- `nginx/nginx.conf`
- `nginx/conf.d/leetshego-http.conf`

## Development Best Practices

### When Making Changes

1. **Always verify isolation is maintained**
   - Check no new shared resources are introduced
   - Verify port allocations remain unique
   - Ensure configuration changes are application-specific

2. **Test independence after changes**
   ```bash
   # After any changes, verify other apps unaffected
   cd /home/mulalo/applications/lss_construction
   ./scripts/deploy.sh restart
   
   # Verify other applications still work
   curl -I https://ndlelasearchengine.co.za
   ```

3. **Document any new resources**
   - Update APPLICATION_ISOLATION.md if adding services
   - Document new port allocations
   - Keep architecture documentation current

### When Adding New Services

1. **Use application-specific naming**
   - Prefix all containers with application name
   - Use application-specific network names
   - Namespace all volumes and configs

2. **Verify no conflicts**
   ```bash
   # Check for port conflicts
   sudo netstat -tlnp | grep <new-port>
   
   # Check for container name conflicts
   docker ps -a | grep <container-name>
   
   # Check for network conflicts
   docker network ls | grep <network-name>
   ```

3. **Update documentation**
   - Add new services to README
   - Update port allocation in APPLICATION_ISOLATION.md
   - Document in this file

### When Troubleshooting

**Never modify another application's resources to fix issues in this application.**

If you encounter conflicts:
1. Change this application's configuration
2. Use different ports/names/resources
3. Maintain isolation at all costs

## Verification Commands

### Check Isolation

```bash
# View this application's containers only
docker ps --filter "name=leetshego"

# View this application's network only
docker network inspect lss_construction_leetshego-network

# Verify port usage
sudo lsof -i :8080
sudo lsof -i :8443
```

### Test Independence

```bash
# Restart this application
cd /home/mulalo/applications/lss_construction
./scripts/deploy.sh restart

# Verify other applications unaffected (should return 200)
curl -I https://ndlelasearchengine.co.za
```

## What This Means for Developers

- **Design for isolation:** Every feature must respect application boundaries
- **No quick fixes:** Never use another app's resources as a shortcut
- **Test isolation:** Every change must include isolation verification
- **Document everything:** All resources must be clearly documented
- **Think independently:** This application should be completely self-contained

## References

- **Full Isolation Documentation:** `/home/mulalo/applications/APPLICATION_ISOLATION.md`
- **Quick Reference:** `/home/mulalo/applications/QUICK_REFERENCE.md`
- **Deployment Scripts:** `/home/mulalo/applications/lss_construction/scripts/`

## Compliance

**This is not a suggestion - it is a mandatory requirement.**

Violating application isolation can cause:
- Cascading failures across multiple applications
- Unexpected downtime
- Difficult-to-debug issues
- Production outages

Always prioritize isolation in every development decision.

---

**Last Updated:** December 1, 2025
**Applies To:** All development work on Leetshego Safety Solutions
