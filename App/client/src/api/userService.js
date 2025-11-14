import { apiFetch } from "./apiClient";

export function getAllUsers(page = 1, limit = 20) {
  console.log(`[User Service]Calling getAllUsers(${page},${limit})`);
  const data = apiFetch(`/user/users/`, {
    method: "GET",
    params: { page: page, limit: limit },
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
