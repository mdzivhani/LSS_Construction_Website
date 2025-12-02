# Static Site File Reference

This repository contains only the Leetshego static website (HTML/CSS/JS) and nginx configuration. It does not include any .NET solution, backend services, or cross-application files.

## Scope
Only validate presence of static assets and nginx config when updating workflows or deployment scripts.

## Project Structure

```
/home/mulalo/applications/lss_construction/
├── index.html
├── about.html
├── contact.html
├── assets/
│   ├── css/
│   ├── js/
│   ├── img/
│   └── vendor/
├── nginx/
│   ├── nginx.conf
│   └── conf.d/leetshego-http.conf
├── docker-compose.yml
├── Dockerfile
└── instructions/
```

## Validation Targets
No solution or backend paths exist. Validate only:

| Path | Purpose | Validation |
|------|---------|------------|
| `assets/` | Static styles/scripts/images | `ls -d assets` |
| `nginx/nginx.conf` | Base nginx config | `ls nginx/nginx.conf` |
| `nginx/conf.d/leetshego-http.conf` | Site server blocks | `ls nginx/conf.d/leetshego-http.conf` |
| `docker-compose.yml` | Container definition | `ls docker-compose.yml` |
| `Dockerfile` | Build definition | `ls Dockerfile` |

### Static Asset Checks

```bash
ls -d assets/css assets/js assets/img assets/vendor
```

### Docker Build Context

Context is repository root; Dockerfile copies static content and nginx configs.

## Example Workflow Snippets

```yaml
# Build and push image
- name: Build image
  uses: docker/build-push-action@v6
  with:
    context: .
    file: ./Dockerfile
    push: false
```

### Frontend Commands

```yaml
# ✅ CORRECT - Use working-directory or cd
- name: Install client dependencies
  run: npm install
  working-directory: frontend/client

# OR
- name: Install client dependencies
  run: |
    cd frontend/client
    npm install

# ✅ CORRECT - Server dependencies
- name: Install server dependencies
  run: npm install
  working-directory: frontend/server
```

### Docker Build Commands

```yaml
# ✅ CORRECT - Backend API context
- name: Build Business API
  uses: docker/build-push-action@v6
  with:
    context: ./backend/services
    file: ./backend/services/SA.Tourism.Business.Api/Dockerfile

# ✅ CORRECT - Frontend context
- name: Build React Client
  uses: docker/build-push-action@v6
  with:
    context: ./frontend/client
    file: ./frontend/client/Dockerfile

# ❌ WRONG - Individual service as context
- name: Build Business API
  uses: docker/build-push-action@v6
  with:
    context: ./backend/services/SA.Tourism.Business.Api
    file: ./backend/services/SA.Tourism.Business.Api/Dockerfile
```

## Quick Validation Script

Run this script before pushing workflow changes:

```bash
#!/bin/bash
echo "Validating static site structure..."
for p in index.html assets nginx/nginx.conf nginx/conf.d/leetshego-http.conf Dockerfile docker-compose.yml; do
  if [ ! -e "$p" ]; then
  echo "❌ Missing: $p"; exit 1; fi
  echo "✅ Found: $p"
done
echo "✅ Static site validation complete"
```

## Common Mistakes to Avoid

1. Avoid adding backend/.NET paths (not part of this repo)
2. Ensure nginx config paths stay accurate
3. Keep Docker context at repository root
4. Minimize workflow steps (build, push, deploy)

## When Modifying Workflows

**Required checklist before committing workflow changes:**

- [ ] Run validation script
- [ ] Confirm required static paths exist
- [ ] Review Docker build step
- [ ] Confirm no backend references added
- [ ] Document any new static asset directories

## Last Validated

Date: December 2, 2025
By: Isolation Cleanup
Static site only; no cross-application references.
