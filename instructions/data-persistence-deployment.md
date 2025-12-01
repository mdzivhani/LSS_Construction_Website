# Data Persistence & Deployment Guide

## Overview

This guide explains how user data is stored, persisted across deployments, and backed up in the Ndlela Search Engine application.

---

## Current Authentication & Data Storage

### Development vs Production

#### **Current State (Development)**
- **User Storage**: In-memory Map in Express server (`frontend/server/routes/auth.router.js`)
- **Database**: PostgreSQL with Docker volume persistence
- **Data Loss Risk**: ⚠️ **YES** - User accounts are lost on Express server restart/redeploy
- **Token**: Simple development token format: `dev-token-{timestamp}-{userId}`

#### **Required for Production** 
- **User Storage**: PostgreSQL database (persistent)
- **Token**: JWT with proper signing and expiration
- **Password Security**: Bcrypt hashing (not plain text)

---

## How Data is Currently Stored

### 1. **User Registration Data**

When you register on the application:

```javascript
// Location: frontend/server/routes/auth.router.js
const users = new Map(); // ⚠️ IN-MEMORY ONLY - LOST ON RESTART

router.post('/register', async (req, res) => {
  const { email, password, name } = req.body;
  const userId = `user-${Date.now()}`;
  
  // Stored in memory only
  users.set(email, {
    id: userId,
    email,
    password,  // ⚠️ Plain text (dev only)
    name
  });
});
```

**Current Behavior**:
- ✅ Works during the same server session
- ❌ **Lost when Express server restarts**
- ❌ **Lost when you redeploy the application**
- ❌ Passwords stored in plain text (development only)

### 2. **Login Session Data**

```javascript
// Token stored in browser localStorage
localStorage.setItem('auth_token', 'dev-token-123456789-user-123');
```

**Current Behavior**:
- ✅ Token persists in your browser (survives page refresh)
- ✅ You stay logged in on the same browser
- ❌ **Token becomes invalid if user data is lost on server restart**
- ❌ No token expiration (development only)

### 3. **Business Data (Tourism Listings)**

```
Location: PostgreSQL Database
Persistence: Docker Volume (ndlela-search-engine_postgres_data)
```

**Current Behavior**:
- ✅ **Persisted across all restarts and redeployments**
- ✅ Survives container recreation
- ✅ Only lost if Docker volume is explicitly deleted

---

## Data Persistence Configuration

### PostgreSQL Database Persistence

```yaml
# docker-compose.prod.yml
postgres:
  image: postgres:15
  volumes:
    - postgres_data:/var/lib/postgresql/data  # ✅ PERSISTENT
    - ./backups:/backups                       # Backup mount point

volumes:
  postgres_data:  # Docker managed volume - survives container deletion
```

**Check Current Volumes**:
```bash
docker volume ls | grep ndlela
# Output:
# ndlela-search-engine_postgres_data  ✅ Contains all database data
```

**What's Persisted**:
- ✅ Business listings and tourism data
- ✅ Search indexes
- ✅ Database schema and migrations
- ❌ User accounts (not yet using database)

---

## Migration Plan: Development → Production

### Phase 1: Move Users to Database ⚠️ **REQUIRED**

#### 1.1 Create User Table Migration

```sql
-- Create users table in PostgreSQL
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    location VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    profile_picture TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
```

#### 1.2 Update Express Server to Use Database

Replace in-memory Map with PostgreSQL queries:

```javascript
// Before (current - in memory)
const users = new Map();
users.set(email, { id, email, password, name });

// After (production - database)
const result = await db.query(
  'INSERT INTO users (email, password_hash, name) VALUES ($1, $2, $3) RETURNING id',
  [email, hashedPassword, name]
);
```

#### 1.3 Add Password Hashing

```javascript
const bcrypt = require('bcrypt');

// Registration
const saltRounds = 10;
const hashedPassword = await bcrypt.hash(password, saltRounds);

// Login
const match = await bcrypt.compare(password, user.password_hash);
```

### Phase 2: Implement Proper JWT Tokens

#### 2.1 Replace Development Tokens

```javascript
// Before (current)
const token = `dev-token-${Date.now()}-${userId}`;

// After (production)
const jwt = require('jsonwebtoken');
const token = jwt.sign(
  { userId, email, name },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);
```

#### 2.2 Add Token Verification Middleware

```javascript
function verifyToken(req, res, next) {
  const token = req.headers['authorization']?.split(' ')[1];
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}
```

---

## Backup & Recovery

### Automatic Backups

#### Create Backup Script

```bash
#!/bin/bash
# Location: scripts/backup-database.sh

BACKUP_DIR="/home/mulalo/applications/ndlela-search-engine/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/ndlela_backup_$TIMESTAMP.sql"

# Create backup
docker exec ndlela-postgres pg_dump -U postgres ndlela > "$BACKUP_FILE"

# Compress
gzip "$BACKUP_FILE"

# Keep only last 30 days
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +30 -delete

echo "Backup completed: ${BACKUP_FILE}.gz"
```

#### Schedule Daily Backups

```bash
# Add to crontab
crontab -e

# Run backup daily at 2 AM
0 2 * * * /home/mulalo/applications/ndlela-search-engine/scripts/backup-database.sh
```

### Manual Backup

```bash
# Create backup
docker exec ndlela-postgres pg_dump -U postgres ndlela > backup_$(date +%Y%m%d).sql

# Restore from backup
docker exec -i ndlela-postgres psql -U postgres ndlela < backup_20251126.sql
```

### Volume Backup (Complete System)

```bash
# Stop containers
docker compose -f docker-compose.prod.yml down

# Backup volume
docker run --rm \
  -v ndlela-search-engine_postgres_data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/postgres_volume_$(date +%Y%m%d).tar.gz /data

# Start containers
docker compose -f docker-compose.prod.yml up -d
```

---

## Deployment Without Data Loss

### Current Issue

```
Redeploy → Express server restarts → In-memory users Map cleared → All accounts lost
```

### Solution: Database-Backed Users

Once users are moved to PostgreSQL (Phase 1 above):

```
Redeploy → PostgreSQL volume persists → All accounts preserved ✅
```

### Deployment Checklist

**Before Every Deployment**:
- [ ] Create database backup
- [ ] Verify backup file exists and is not empty
- [ ] Test backup restore in dev environment (optional)
- [ ] Ensure `.env.production` has correct database credentials

**During Deployment**:
```bash
# 1. Backup database
./scripts/backup-database.sh

# 2. Pull latest code
git pull origin main

# 3. Rebuild only changed services
docker compose -f docker-compose.prod.yml build

# 4. Restart services (database stays running)
docker compose -f docker-compose.prod.yml up -d

# 5. Verify services
docker compose -f docker-compose.prod.yml ps
```

**After Deployment**:
- [ ] Test login with existing account
- [ ] Create new test account
- [ ] Verify search functionality
- [ ] Check database connection: `docker exec ndlela-postgres psql -U postgres -d ndlela -c "\dt"`

---

## Docker Volume Management

### View Volumes

```bash
# List all volumes
docker volume ls

# Inspect volume
docker volume inspect ndlela-search-engine_postgres_data
```

### Volume Location

```json
{
  "Mountpoint": "/var/lib/docker/volumes/ndlela-search-engine_postgres_data/_data"
}
```

### Backup Volume Directly

```bash
# As root or with sudo
sudo tar czf postgres_volume_backup.tar.gz \
  -C /var/lib/docker/volumes/ndlela-search-engine_postgres_data/_data .
```

### Restore Volume

```bash
# Stop containers
docker compose -f docker-compose.prod.yml stop postgres

# Restore data
sudo tar xzf postgres_volume_backup.tar.gz \
  -C /var/lib/docker/volumes/ndlela-search-engine_postgres_data/_data

# Start containers
docker compose -f docker-compose.prod.yml start postgres
```

---

## Current Limitations & Risks

### ⚠️ Critical Issues

1. **User Data Loss on Redeploy**
   - **Risk**: All registered users are lost when Express server restarts
   - **Impact**: Users must re-register after every deployment
   - **Fix**: Implement Phase 1 (Move users to database)

2. **Plain Text Passwords**
   - **Risk**: Passwords stored without encryption
   - **Impact**: Security vulnerability
   - **Fix**: Add bcrypt hashing (Phase 1.3)

3. **No Token Expiration**
   - **Risk**: Tokens never expire
   - **Impact**: Stolen tokens remain valid forever
   - **Fix**: Implement proper JWT with expiration (Phase 2)

### ✅ What's Already Protected

1. **Business Data**: Fully persisted in PostgreSQL with Docker volumes
2. **Database Schema**: Migrations survive restarts
3. **Uploaded Files**: Avatars stored in Docker volumes
4. **SSL Certificates**: Mounted from host filesystem (`/etc/letsencrypt`)

---

## Implementation Priority

### 🔴 High Priority (Before Production)

1. **Move user authentication to PostgreSQL database**
   - Create users table
   - Update Express routes to use database
   - Add password hashing with bcrypt
   - Test registration and login

2. **Implement proper JWT tokens**
   - Add jsonwebtoken package
   - Set JWT_SECRET in environment
   - Add expiration (7 days recommended)
   - Update token verification middleware

3. **Set up automated backups**
   - Create backup script
   - Schedule daily cron job
   - Test restore procedure

### 🟡 Medium Priority (Post-Launch)

4. **Add email verification**
5. **Implement password reset flow**
6. **Add rate limiting for login attempts**
7. **Set up monitoring and alerts**

### 🟢 Low Priority (Future Enhancements)

8. **Add OAuth/Social login**
9. **Implement 2FA**
10. **Add session management dashboard**

---

## Testing Data Persistence

### Test User Persistence

```bash
# 1. Register a user on the website
curl -X POST https://ndlelasearchengine.co.za/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123","name":"Test User"}'

# 2. Restart Express server
docker compose -f docker-compose.prod.yml restart express-server

# 3. Try to login (will fail with current implementation)
curl -X POST https://ndlelasearchengine.co.za/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'
# Expected: 401 Unauthorized (user data lost)

# After implementing database persistence, login will succeed ✅
```

### Test Database Persistence

```bash
# 1. Add business data
docker exec -i ndlela-postgres psql -U postgres ndlela << EOF
INSERT INTO businesses (name, description, category) 
VALUES ('Test Business', 'Test Description', 'Accommodation');
EOF

# 2. Restart all containers
docker compose -f docker-compose.prod.yml restart

# 3. Verify data still exists
docker exec ndlela-postgres psql -U postgres ndlela \
  -c "SELECT * FROM businesses WHERE name='Test Business';"
# Expected: Data still present ✅
```

---

## Environment Variables for Production

### Required for Database-Backed Authentication

```bash
# .env.production
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_DB=ndlela

# JWT Configuration
JWT_SECRET=your_very_long_random_secret_key_at_least_32_characters
JWT_EXPIRATION=7d

# Node Environment
NODE_ENV=production
```

### Generate Secure Secrets

```bash
# Generate JWT secret
openssl rand -base64 48

# Generate PostgreSQL password
openssl rand -base64 32
```

---

## Monitoring & Health Checks

### Check Database Connection

```bash
# From host
docker exec ndlela-postgres pg_isready -U postgres

# Check tables
docker exec ndlela-postgres psql -U postgres ndlela -c "\dt"

# Check user count (after implementing database users)
docker exec ndlela-postgres psql -U postgres ndlela \
  -c "SELECT COUNT(*) FROM users;"
```

### Check Volume Space

```bash
# Check Docker volume disk usage
docker system df -v | grep ndlela
```

### Application Health

```bash
# All services status
docker compose -f docker-compose.prod.yml ps

# Database logs
docker logs ndlela-postgres --tail 50

# Express server logs
docker logs ndlela-express-server --tail 50
```

---

## Summary

### Current State
- ✅ **Users**: Stored in PostgreSQL via Express (bcrypt + JWT)
- ✅ **Business Data**: PostgreSQL with Docker volumes (persistent)
- ✅ **Database**: Fully persisted across restarts
- ❌ **Tokens**: Development-only format
- ❌ **Passwords**: Plain text (insecure)

### Required Changes for Production
1. Set up automated daily backups
2. Test full backup and restore procedure
3. Optional: migrate to dedicated .NET Auth microservice later

### Data Persistence Matrix

| Data Type | Current Storage | Persists on Restart | Persists on Redeploy | Backed Up |
|-----------|----------------|--------------------|--------------------|-----------|
| User Accounts | In-Memory Map | ❌ NO | ❌ NO | ❌ NO |
| User Sessions (tokens) | Browser localStorage | ✅ YES | ⚠️ Only if server has user | ❌ NO |
| Business Listings | PostgreSQL Volume | ✅ YES | ✅ YES | ✅ YES (manual) |
| Database Schema | PostgreSQL Volume | ✅ YES | ✅ YES | ✅ YES (manual) |
| Uploaded Files | Docker Volume | ✅ YES | ✅ YES | ⚠️ Manual |
| SSL Certificates | Host Filesystem | ✅ YES | ✅ YES | ✅ Auto-renewed |

### After Implementation

| Data Type | Storage | Persists on Restart | Persists on Redeploy | Backed Up |
|-----------|---------|--------------------|--------------------|-----------|
| User Accounts | PostgreSQL | ✅ YES | ✅ YES | ✅ YES (automated) |
| Everything else | Same as above | ✅ YES | ✅ YES | ✅ YES |

---

## Next Steps

1. **Review this document** with the development team
2. **Prioritize implementation** of database-backed authentication
3. **Create backup scripts** and test restore procedures
4. **Update deployment checklist** in CI/CD workflows
5. **Test in staging** environment before production rollout

---

## References

- PostgreSQL Documentation: https://www.postgresql.org/docs/
- bcrypt npm package: https://www.npmjs.com/package/bcrypt
- jsonwebtoken npm package: https://www.npmjs.com/package/jsonwebtoken
- Docker Volumes: https://docs.docker.com/storage/volumes/

---

**Last Updated**: November 26, 2025  
**Status**: ⚠️ **Action Required** - User persistence not yet implemented
