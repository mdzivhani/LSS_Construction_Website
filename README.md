# Leetshego Safety Solutions Website

A branded, multi-page static website for Leetshego Safety Solutions (LSS) showcasing high visibility clothing, reflective products, and health & safety PPE. Built with Bootstrap 5 and common front‑end libraries. Optimized for clarity, accessibility, and fast contact via WhatsApp.

## Features
- Streamlined navigation: `Home | About | Services | Projects | Contact`
- WhatsApp CTA to Tshepo Mzimba for quick inquiries
- Product detail page for High Visibility Clothing (supply process + care)
- Legal pages (Terms, Privacy) with clean, single‑H1 semantics
- Mobile‑friendly layout, animations (AOS), gallery (Glightbox), slider (Swiper)

## Tech Stack
- HTML5, CSS, JavaScript
- Bootstrap 5.3.8
- Vendor libs: AOS, Swiper, Glightbox
- Structure under `assets/` (css, js, vendor, img)

## Project Structure
```
.
├─ index.html
├─ about.html
├─ services.html
├─ service-details.html
├─ projects.html
├─ project-details.html
├─ contact.html
├─ quote.html
├─ terms.html
├─ privacy.html
├─ 404.html
├─ assets/
│  ├─ css/main.css
│  ├─ js/main.js
│  ├─ img/
│  └─ vendor/
└─ forms/
   ├─ contact.php
   └─ get-a-quote.php
```

## Brand & Contact
- Tagline: Your Safety is Our Priority | Established 2017 | 100% South African Products
- Email: `Leetshego@gmail.com`
- Phone: `078 287 9661` | `067 774 6135`
- WhatsApp: `https://wa.me/27782879661`
- Address: 02 Kelly Road, Jet Park, Boksburg, South Africa

## Getting Started (Local)
Use any static server. Examples:

```powershell
# PowerShell: quick local server (Python if available)
python -m http.server 5500
# Then open http://localhost:5500/

# Or use VS Code Live Server extension
```

Alternatively, open `index.html` directly in a browser (note: some features like AJAX forms may require a server).

## Deployment
- GitHub Pages: Set the Pages source to the `main` branch `/` (root). The site is static and deployable as‑is.
- Any static hosting (Netlify, Vercel, Azure Static Web Apps) works. Upload root directory or connect the repo.

## Maintenance Tasks
- Replace stock images with authentic LSS product/project media; add descriptive `alt` text.
- Align `services.html` cards with final three groups: Brickwork & Plastering, Exterior & Interior Painting, Health & Safety PPE Supply.
- Update `projects.html` with real case images and titles; convert `project-details.html` into LSS case study.
- Add analytics or contact tracking if desired.

## License
This repository contains third‑party vendor assets (Bootstrap, AOS, Swiper, Glightbox) under their respective licenses. Site content © Leetshego Safety Solutions.
