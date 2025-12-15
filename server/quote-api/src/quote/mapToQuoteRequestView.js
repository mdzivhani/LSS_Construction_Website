import { sanitize } from './sanitize.js';

export function mapToQuoteRequestView(payload = {}) {
  const name = sanitize(String(payload.name || '').trim());
  const email = sanitize(String(payload.email || '').trim());
  const phone = sanitize(String(payload.phone || '').trim());
  const productCategory = sanitize(String(payload.productCategory || '').trim());
  const deliveryDateRaw = String(payload.deliveryDate || '').trim();
  const estimatedQuantityRaw = String(payload.estimatedQuantity || '').trim();
  const orderDetails = sanitize(String(payload.orderDetails || '').trim());

  const deliveryDate = sanitize(deliveryDateRaw);
  const estimatedQuantity = sanitize(estimatedQuantityRaw);

  return {
    customer: { name, email, phone },
    request: {
      productCategory,
      deliveryDate: deliveryDate || undefined,
      estimatedQuantity: estimatedQuantity || undefined,
      orderDetails
    },
    meta: {
      requestedAt: new Date().toISOString().slice(0, 19).replace('T', ' ')
    }
  };
}
