import { apiFetch } from "./apiClient";

export function getAllOrders(page = 1, limit = 20) {
  console.log(`[Order Service]Calling getAllOrders(${page},${limit})`);
  const data = apiFetch(`/order/orders/`, {
    method: "GET",
    params: { page: page, limit: limit },
  });
  return data;
}

export function getOrdersByUser(UserID, page = 1, limit = 20) {
  console.log(`[Order Service]Calling getOrdersByUser(${page},${limit})`);
  const data = apiFetch(`/order/orders/${UserID}`, {
    method: "GET",
    params: { page: page, limit: limit },
  });
  return data;
}

export function updateOrderStatus(orderId, newStatus) {
  console.log(`[Order Service]Calling updateOrderStatus(${orderId},${newStatus})`);
  const data = apiFetch(`/order/${orderId}/status`, {
    method: "PUT",
    body: {
      newStatus: newStatus
    }
  });
  return data;
}