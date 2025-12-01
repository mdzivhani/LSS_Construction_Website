# Content Management Guide

This guide explains how to update and maintain the LSS Construction website content.

## Website Pages

The site consists of the following pages:

### Main Pages
- `index.html` - Home page with company overview and featured services
- `about.html` - About Leetshego Safety Solutions
- `services.html` - Complete services listing
- `service-details.html` - Detailed service information
- `projects.html` - Portfolio/case studies
- `project-details.html` - Individual project details
- `contact.html` - Contact form and company details
- `quote.html` - Request a quote form

### Supporting Pages
- `team.html` - Team members (if applicable)
- `terms.html` - Terms and conditions
- `privacy.html` - Privacy policy
- `404.html` - Custom error page

## Updating Content

### 1. Edit HTML Files

Edit files directly in `/home/mulalo/applications/lss_construction/`:

```bash
cd /home/mulalo/applications/lss_construction
nano index.html  # or use your preferred editor
```

### 2. Update Images

Place images in `assets/img/`:

```bash
# Copy new image
cp /path/to/new-image.jpg assets/img/

# Reference in HTML
<img src="assets/img/new-image.jpg" alt="Description">
```

**Image Guidelines:**
- Use descriptive filenames (e.g., `high-vis-jacket-orange.jpg`)
- Optimize images before upload (compress for web)
- Always add meaningful `alt` text for accessibility
- Recommended formats: JPG for photos, PNG for logos/graphics

### 3. Update Styles

Main CSS file: `assets/css/main.css`

```bash
nano assets/css/main.css
```

### 4. Update JavaScript

Main JS file: `assets/js/main.js`

```bash
nano assets/js/main.js
```

### 5. Rebuild and Deploy

After making changes:

```bash
cd /home/mulalo/applications/lss_construction
docker compose up -d --build
```

**Note:** Browsers cache CSS/JS. Users may need to hard refresh (Ctrl+F5) to see changes.

## Contact Information Updates

Update contact details in these locations:

### Header/Footer (all pages)
Search for and update:
- Email: `Leetshego@gmail.com`
- Phone: `078 287 9661` / `067 774 6135`
- WhatsApp: `https://wa.me/27782879661`
- Address: `02 Kelly Road, Jet Park, Boksburg, South Africa`

### Meta Tags (each HTML file)
Update in `<head>` section:
```html
<meta name="description" content="...">
<meta name="keywords" content="...">
<title>Page Title</title>
```

## Form Configuration

The contact forms currently use PHP files in the `forms/` directory:
- `forms/contact.php`
- `forms/get-a-quote.php`

**Current Status:** These require a PHP backend to function. Options:

1. **Set up PHP-FPM** in Docker (recommended for dynamic forms)
2. **Use a form service** like Formspree, Google Forms, or Netlify Forms
3. **Replace with JavaScript** submission to an API endpoint

## SEO Best Practices

When updating content:

1. **Title Tags:** Unique for each page, 50-60 characters
2. **Meta Descriptions:** 150-160 characters, compelling summary
3. **Headings:** One H1 per page, logical H2-H6 hierarchy
4. **Alt Text:** All images must have descriptive alt attributes
5. **Internal Links:** Link related pages together
6. **Mobile-Friendly:** Test on mobile devices after changes

## Adding New Pages

To add a new page:

1. Copy an existing page as a template:
   ```bash
   cp services.html new-page.html
   ```

2. Update the content, keeping the header/footer structure

3. Add navigation link in header (all pages):
   ```html
   <li><a href="new-page.html">New Page</a></li>
   ```

4. Rebuild container:
   ```bash
   docker compose up -d --build
   ```

## Content Recommendations

Based on the README, consider updating:

### Priority Updates
1. **Replace stock images** with real LSS photos:
   - Product photos (high-vis clothing, PPE)
   - Team/staff photos
   - Completed projects

2. **Update services.html** with final three groups:
   - Brickwork & Plastering
   - Exterior & Interior Painting
   - Health & Safety PPE Supply

3. **Projects page** with real case studies:
   - Before/after photos
   - Client testimonials
   - Project descriptions

### Brand Consistency
Ensure all pages reflect:
- **Tagline:** "Your Safety is Our Priority"
- **Established:** 2017
- **Quality:** 100% South African Products

## Testing Changes

After updates, test:

1. **Local test:** http://localhost:8080
2. **Live site:** http://leetshego.co.za (or https:// after SSL)
3. **Mobile view:** Use browser DevTools or real devices
4. **Forms:** Submit test data (if functional)
5. **Links:** Click all navigation and internal links
6. **Images:** Verify all images load correctly

## Backup Before Major Changes

Before significant updates:

```bash
# Backup current site
cd /home/mulalo/applications
tar -czf lss_construction_backup_$(date +%Y%m%d).tar.gz lss_construction/

# Restore if needed
tar -xzf lss_construction_backup_YYYYMMDD.tar.gz
```

## Version Control

The site is in a Git repository. Commit changes:

```bash
cd /home/mulalo/applications/lss_construction
git add .
git commit -m "Update: description of changes"
git push origin main
```

## Getting Help

If you encounter issues:

1. Check container logs: `docker logs leetshego-nginx`
2. Check Nginx logs: `tail -f /home/mulalo/logs/lss_construction/error.log`
3. Test Nginx config: `docker exec leetshego-nginx nginx -t`
4. Restart container: `docker compose restart`

## Analytics (Future Enhancement)

Consider adding Google Analytics for tracking:
- Page views
- User behavior
- Traffic sources
- Conversion tracking (quote requests, contact form submissions)
