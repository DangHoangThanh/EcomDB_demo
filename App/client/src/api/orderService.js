import { apiFetch } from "./apiClient";

export function getAllOrders(page = 1, limit = 20) {
  console.log(`[Order Service]Calling getAllOrders(${page},${limit})`);
  const data = apiFetch(`/order/orders/`, {
    method: "GET",
    params: { page: page, limit: limit },
  });
  return data;
}