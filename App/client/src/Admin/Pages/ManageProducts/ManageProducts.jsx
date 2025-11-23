import "./ManageProducts.css";
import React, { useState, useEffect } from "react";
// import all_product from "../../../data/all_product";
import { FaPlusCircle } from "react-icons/fa";
import { getAllProducts } from "../../../api/productService";

import AdminItemRow from "../../Components/AdminItemRow/AdminItemRow";
import ProductForm from "../../Components/ProductForm/ProductForm";
import LoadingOverlay from "../../../Components/LoadingOverlay/LoadingOverlay";

function ManageProducts() {
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [products, setProducts] = useState([]);
  const [totalProducts, setTotalProducts] = useState(0);
  const limit = 20;

  // Fetch products method (from all product)
  const fetchProducts = async (page = 1, limit = 20) => {
    setLoading(true);
    try {
      const response = await getAllProducts(page, limit);
      const resProducts = response.products;
      const resPagination = response.pagination;
      
      setProducts(resProducts);
      setTotalProducts(resPagination.TotalCount);
      setTotalPages(resPagination.TotalPages);
    } catch (error) {
      console.log(error);
      alert("Fetch products failed");
    }
    setLoading(false);
  };

  // Fetch new page upon page change
  useEffect(() => {
    fetchProducts(currentPage, limit);
  }, [currentPage]);

  // State of  ProductForm
  const [isFormVisible, setIsFormVisible] = useState(false);
  const [formMode, setFormMode] = useState("");
  const [formCurrentItem, setFormCurrentItem] = useState(null);

  // Open form with mode "add", "edit", "delete"
  const openForm = (mode, currentItem = null) => {
    setFormMode(mode);
    setFormCurrentItem(currentItem);
    setIsFormVisible(true);
  };

  return (
    <div className="ManageProducts-container">
      {loading && <LoadingOverlay/>}
      <div id="ManageProducts-header">
        <h2 style={{ color: "white" }}>📦Quản lí sản phẩm</h2>
      </div>

      <div className="ManageProducts-table-container">
        <header>Danh sách các sản phẩm</header>

        <div>Tổng cộng {totalProducts} sản phẩm</div>


        <table>
          <thead>
            <tr>
              <th className="index">#</th>
              <th>Hình ảnh</th>
              <th>Tên sản phẩm</th>
              <th>Phân loại</th>
              <th>Giá thành/1</th>
              <th>Mô tả sản phẩm</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {products.map((item, i) => {
              const index = i + 1 + (currentPage - 1) * limit;
              return (
                <AdminItemRow
                  key={i}
                  index={index}
                  {...item}
                  onEdit={() => openForm("edit", item)}
                  onDelete={() => openForm("delete", item)}
                />
              );
            })}
          </tbody>
        </table>

        {/* Paging for products */}
        <div className="ManageProducts-paging">
          <button
            onClick={() => setCurrentPage(currentPage - 1)}
            disabled={currentPage <= 1}
          >
            Trước
          </button>

          <span>
            Trang {currentPage} trên {totalPages}
          </span>

          <button
            onClick={() => setCurrentPage(currentPage + 1)}
            disabled={currentPage >= totalPages}
          >
            Sau
          </button>
        </div>
      </div>

      <button id="add-product" onClick={() => openForm("add")}>
        <FaPlusCircle />
        Thêm sản phẩm
      </button>

      {/* Conditional Rendering of ProductForm */}
      {isFormVisible && (
        <div id="ProductForm-overlay">
          <ProductForm
            mode={formMode}
            currentItem={formCurrentItem}
            onCancel={() => setIsFormVisible(false)} // Pass a function to close the form
            onSuccess={() => fetchProducts(currentPage, limit)}
            setLoading={(state) => setLoading(state)}
          />
        </div>
      )}
    </div>
  );
}

export default ManageProducts;
