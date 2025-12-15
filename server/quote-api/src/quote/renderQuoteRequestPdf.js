import fs from 'fs/promises';
import path from 'path';
import Mustache from 'mustache';
import { chromium } from 'playwright';

export async function renderQuoteRequestPdf(view) {
  const tplPath = path.join(process.cwd(), 'templates', 'quote-request.html');
  const template = await fs.readFile(tplPath, 'utf-8');
  const html = Mustache.render(template, view, {});

  const browser = await chromium.launch({
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-gpu',
      '--font-render-hinting=none'
    ]
  });
  try {
    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'networkidle' });
    const pdf = await page.pdf({
      format: 'A4',
      printBackground: true,
      margin: { top: '20mm', right: '16mm', bottom: '20mm', left: '16mm' }
    });
    await page.close();
    return pdf;
  } finally {
    await browser.close();
  }
}
