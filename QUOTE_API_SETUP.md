# Quote API Setup & Testing

## Overview
The quote form sends requests to `/api/quote-request`, which is proxied by Nginx to a Node/Express backend. The backend validates submissions, sends an HTML email to `Leetshegoss@gmail.com`, and optionally attaches a PDF summary.

## Configuration

### 1. Environment Variables
Create a `.env` file in the project root (copied from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` and set your SMTP credentials:
- `TO_EMAIL`: Target email (default `Leetshegoss@gmail.com`)
- `SMTP_HOST`: SMTP server (e.g., `smtp.gmail.com`)
- `SMTP_PORT`: Port (usually `465` for SSL or `587` for TLS)
- `SMTP_SECURE`: `true` for SSL, `false` for TLS
- `SMTP_USER`: Your email account
- `SMTP_PASS`: Your email password or app-specific password
- `FROM_EMAIL`: Sender address (defaults to `SMTP_USER`)

**Gmail users**: enable 2FA and generate an [App Password](https://support.google.com/accounts/answer/185833?hl=en) instead of using your main password.

### 2. Docker Compose
The `docker-compose.yml` includes:
- `nginx` service: serves static site and proxies `/api/*` to the backend
- `quote-api` service: Node backend (port 3000) that handles quote submissions

Environment variables are read from `.env` (via `docker-compose` variable interpolation).

## Deployment

1. **Build and start services:**
   ```bash
   docker-compose up --build -d
   ```

2. **Check logs:**
   ```bash
   docker-compose logs -f quote-api
   ```

3. **Verify health:**
   ```bash
   curl -I http://localhost:8080/health
   curl -I http://localhost:3000
   ```

## Testing

### Manual Form Submission
1. Navigate to `https://leetshego.co.za/quote.html` (or `http://localhost:8080/quote.html` locally).
2. Fill in all required fields:
   - Name, email, phone
   - Product category (select from dropdown)
   - Delivery timeline
   - Order details
3. Click "Request Quote."
4. Success: green confirmation message appears and form resets.
5. Error: red error message displays with details.

### API Test (curl)
```bash
curl -X POST https://leetshego.co.za/api/quote-request \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "testuser@example.com",
    "phone": "+27 82 123 4567",
    "productCategory": "High Visibility Clothing",
    "deliveryDate": "1-2 Weeks",
    "estimatedQuantity": "50",
    "orderDetails": "Need 50 high-vis vests, size large, with reflective strips. Urgent order for construction site."
  }'
```

Expected response:
```json
{"ok": true}
```

### Verify Email
Check `Leetshegoss@gmail.com` for:
- Subject: `New quote request from Test User – Leetshego Safety Solutions`
- HTML body with table layout
- PDF attachment (if generated successfully)

## Troubleshooting

- **503 errors**: Backend not ready; check `docker-compose logs quote-api` for startup errors.
- **Validation errors**: Ensure all required fields (name, email, phone, productCategory, orderDetails) are provided and valid.
- **Email not received**: Verify SMTP credentials in `.env`; check spam folder; review backend logs for nodemailer errors.
- **PDF not attached**: Non-critical; email still sends. Check logs for PDFKit errors.

## Architecture

- **Frontend**: `quote.html` with inline JS for fetch-based submission
- **Nginx proxy**: `/api/*` → `http://leetshego-quote-api:3000/`
- **Backend**: Express server (`server/quote-api/server.js`) validates, sends email via Nodemailer, generates PDF via PDFKit

## Security Notes
- Never commit `.env` (already in `.gitignore`).
- Use app-specific passwords for SMTP.
- Rotate credentials if exposed.
- HTTPS enforced on production; Nginx redirects HTTP → HTTPS.
