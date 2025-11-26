import { apiFetch } from "./apiClient";

export function getAllUsers(page = 1, limit = 20) {
  console.log(`[User Service]Calling getAllUsers(${page},${limit})`);
  const data = apiFetch(`/user/users/`, {
    method: "GET",
    params: { page: page, limit: limit },
  });
  return data;
}

export function getAllCustomers(page = 1, limit = 20) {
  console.log(`[User Service]Calling getAllCustomers(${page},${limit})`);
  const data = apiFetch(`/user/customers/`, {
    method: "GET",
    params: { page: page, limit: limit },
  });
  return data;
}

export function signInAdmin(email = '', password = '') {
  console.log(`[User Service]Calling signInAdmin(${email},${password})`);
  const data = apiFetch(`/user/admin/signin`, {
    method: "POST",
    body: { Email: email, Password: password },
  });
  return data;
}

export function getTopPurchased(UserID = null, limit = 5) {
  console.log(`[User Service]Calling getTopPurchased(${UserID},${limit})`);
  const data = apiFetch(`/user/${UserID}/toppurchased`, {
    method: "GET",
    params: {limit: limit },
  });
  return data;
}
