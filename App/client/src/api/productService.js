import { apiFetch } from "./apiClient";

export function getAllProducts(page = 1, limit = 20) {
  console.log(`[Product Service]Calling getAllProducts(${page},${limit})`);
  const data = apiFetch(`/product/products/`, {
    method: "GET",
    params: { page: page, limit: limit },
  });
  return data;
}

export function getProductsByCategory(category, page = 1, limit = 20) {
  console.log(`[Product Service]Calling getProductsByCategory(${category},${page},${limit})`);
  const data = apiFetch(`/product/products/category`, {
    method: "GET",
    params: { category:category, page: page, limit: limit },
  });
  return data;
}

export function getProductsSortedByPrice(order, page = 1, limit = 20) {
  console.log(`[Product Service]Calling getProductsSortedByPrice(${order},${page},${limit})`);
  const data = apiFetch(`/product/products/sorted`, {
    method: "GET",
    params: { order:order, page: page, limit: limit },
  });
  return data;
}

export function searchProducts(query, page = 1, limit = 20) {
  console.log(`[Product Service]Calling searchProducts(${query},${page},${limit})`);
  const data = apiFetch(`/product/products/search`, {
    method: "GET",
    params: { query:query, page: page, limit: limit },
  });
  return data;
}

export async function newProduct(productInfo) {
  console.log(`[Product Service]Calling newProduct()`);
  const data = apiFetch(`/product/new`, {
    method: "POST",
    body: {
      TenSP: productInfo.TenSP,
      GiaTien: productInfo.GiaTien,
      MoTa: productInfo.MoTa,
      LoaiSP: productInfo.LoaiSP,
    },
  });
  return data;
}

export async function editProduct(MaSP, productInfo) {
  console.log(`[Product Service]Calling editProduct(${MaSP})`);
  const data = apiFetch(`/product/${MaSP}/edit`, {
    method: "PUT",
    body: {
      TenSP: productInfo.TenSP,
      GiaTien: productInfo.GiaTien,
      MoTa: productInfo.MoTa,
      LoaiSP: productInfo.LoaiSP,
    },
  });
  return data;
}

export async function deleteProduct(MaSP) {
  console.log(`[Product Service]Calling deleteProduct(${MaSP})`);
  const data = apiFetch(`/product/${MaSP}`, {
    method: "DELETE",
  });
  return data;
}
