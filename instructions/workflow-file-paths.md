# Workflow File Path Validation

This document serves as the authoritative reference for all file paths used in CI/CD workflows. All workflow files MUST use these exact paths.

## Critical Rule
**ALWAYS verify file paths exist before updating workflows. Run validation commands below.**

## Project Structure

```
ndlela-search-engine/
├── Ndlela Search Engine.sln          # Root-level solution file
├── backend/
│   └── services/                      # All .NET projects here
│       ├── SA.Tourism.Auth.Api/
│       │   ├── Dockerfile
│       │   └── SA.Tourism.Auth.Api.csproj
│       ├── SA.Tourism.Business.Api/
│       │   ├── Dockerfile
│       │   └── SA.Tourism.Business.Api.csproj
│       ├── SA.Tourism.Business.Models/
│       ├── SA.Tourism.Business.Services/
│       ├── SA.Tourism.Business.Infrastructure/
│       ├── SA.Tourism.Business.Tests/
│       ├── SA.Tourism.Search.Api/
│       ├── SA.Tourism.Search.Models/
│       ├── SA.Tourism.Search.Services/
│       └── SA.Tourism.Search.Tests/
└── frontend/
    ├── client/
    │   ├── Dockerfile
    │   ├── package.json
    │   └── src/
    └── server/
        ├── Dockerfile
        ├── package.json
        └── routes/
```

## Validated File Paths

### .NET Solution and Projects

| Path | Purpose | Validation Command |
|------|---------|-------------------|
| `"Ndlela Search Engine.sln"` | Root solution file | `ls "Ndlela Search Engine.sln"` |
| `backend/services/` | All .NET projects | `ls -d backend/services` |
| `backend/services/SA.Tourism.Auth.Api/` | Auth API project | `ls -d backend/services/SA.Tourism.Auth.Api/` |
| `backend/services/SA.Tourism.Business.Api/` | Business API project | `ls -d backend/services/SA.Tourism.Business.Api/` |

### Frontend Paths

| Path | Purpose | Validation Command |
|------|---------|-------------------|
| `frontend/client/` | React/Vite client | `ls -d frontend/client` |
| `frontend/client/package.json` | Client dependencies | `ls frontend/client/package.json` |
| `frontend/client/Dockerfile` | Client Docker build | `ls frontend/client/Dockerfile` |
| `frontend/server/` | Express.js server | `ls -d frontend/server` |
| `frontend/server/package.json` | Server dependencies | `ls frontend/server/package.json` |
| `frontend/server/Dockerfile` | Server Docker build | `ls frontend/server/Dockerfile` |

### Docker Build Contexts

| Service | Context Path | Dockerfile Path | Validation |
|---------|-------------|-----------------|------------|
| Auth API | `./backend/services` | `./backend/services/SA.Tourism.Auth.Api/Dockerfile` | `ls backend/services/SA.Tourism.Auth.Api/Dockerfile` |
| Business API | `./backend/services` | `./backend/services/SA.Tourism.Business.Api/Dockerfile` | `ls backend/services/SA.Tourism.Business.Api/Dockerfile` |
| Express Server | `./frontend/server` | `./frontend/server/Dockerfile` | `ls frontend/server/Dockerfile` |
| React Client | `./frontend/client` | `./frontend/client/Dockerfile` | `ls frontend/client/Dockerfile` |

## Correct Workflow Commands

### .NET Commands (ci.yml, ci-dev.yml, deploy-production.yml)

```yaml
# ✅ CORRECT - Use root-level solution file
- name: Restore dependencies
  run: dotnet restore "Ndlela Search Engine.sln"

- name: Build backend
  run: dotnet build "Ndlela Search Engine.sln" --no-restore -c Release

- name: Run tests
  run: dotnet test "Ndlela Search Engine.sln" --no-build -c Release

# ❌ WRONG - Don't cd into backend/
- name: Restore dependencies
  run: |
    cd backend
    dotnet restore

# ❌ WRONG - Solution is not in backend/
- name: Restore dependencies
  run: dotnet restore backend/Ndlela\ Search\ Engine.sln
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

## Validation Script

Run this script before pushing workflow changes:

```bash
#!/bin/bash
echo "Validating workflow file paths..."

# Solution file
if [ ! -f "Ndlela Search Engine.sln" ]; then
    echo "❌ FAIL: Solution file not found at root"
    exit 1
fi
echo "✅ Solution file: Ndlela Search Engine.sln"

# Backend structure
if [ ! -d "backend/services" ]; then
    echo "❌ FAIL: backend/services directory not found"
    exit 1
fi
echo "✅ Backend services directory exists"

# Backend Dockerfiles
for service in "SA.Tourism.Auth.Api" "SA.Tourism.Business.Api"; do
    if [ ! -f "backend/services/$service/Dockerfile" ]; then
        echo "❌ FAIL: backend/services/$service/Dockerfile not found"
        exit 1
    fi
    echo "✅ Dockerfile: backend/services/$service/Dockerfile"
done

# Frontend structure
for dir in "frontend/client" "frontend/server"; do
    if [ ! -d "$dir" ]; then
        echo "❌ FAIL: $dir directory not found"
        exit 1
    fi
    if [ ! -f "$dir/package.json" ]; then
        echo "❌ FAIL: $dir/package.json not found"
        exit 1
    fi
    if [ ! -f "$dir/Dockerfile" ]; then
        echo "❌ FAIL: $dir/Dockerfile not found"
        exit 1
    fi
    echo "✅ Frontend: $dir (package.json, Dockerfile)"
done

echo ""
echo "✅ All file paths validated successfully!"
```

## Common Mistakes to Avoid

1. **Using `cd backend` before dotnet commands** - The solution file is at root level, not in backend/
2. **Using backend/ prefix for solution file** - It's `"Ndlela Search Engine.sln"` not `backend/Ndlela Search Engine.sln`
3. **Wrong Docker context for backend APIs** - Use `./backend/services` (parent directory), not the individual service directory
4. **Forgetting quotes around solution filename** - The solution file has spaces in the name, always use quotes

## When Modifying Workflows

**Required checklist before committing workflow changes:**

- [ ] Run validation script above
- [ ] Verify all dotnet commands use `"Ndlela Search Engine.sln"`
- [ ] Verify no `cd backend` commands before dotnet operations
- [ ] Verify Docker contexts use `./backend/services` for backend APIs
- [ ] Verify Docker contexts use `./frontend/client` or `./frontend/server` for frontend
- [ ] Test workflow locally if possible
- [ ] Document any new paths in this file

## Last Validated

Date: November 26, 2025
By: GitHub Copilot
All paths verified against actual repository structure.
