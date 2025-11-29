import "./ManageProducts.css";
import React, { useState, useEffect } from "react";
import { FaPlusCircle } from "react-icons/fa";

// Import components
import AdminItemRow from "../../Components/AdminItemRow/AdminItemRow";
import ProductForm from "../../Components/ProductForm/ProductForm";
import LoadingOverlay from "../../../Components/LoadingOverlay/LoadingOverlay";


// Import APIs
import {
  getAllProducts,
  getProductsByCategory,
  getProductsSortedByPrice,
  searchProducts
} from "../../../api/productService";


// Import utils
import useDebounce from "../../../utils/useDebounce";


function ManageProducts() {
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [products, setProducts] = useState([]);
  const [totalProducts, setTotalProducts] = useState(0);
  const limit = 20;

  const [searchTerm, setSearchTerm] = useState("");
  const debouncedSearchTerm = useDebounce(searchTerm, 500);
  const [selectedProductCategory, setSelectedProductCategory] = useState("Tất cả");
  const [selectedSortOrder, setSelectedSortOrder] = useState("Default");

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

  // Fetch products method (from all product)
  const fetchProductsByCategory = async (category, page = 1, limit = 20) => {
    setLoading(true);
    try {
      const response = await getProductsByCategory(category, page, limit);
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

  // Fetch products method (from all product)
  const fetchProductsSorted = async (order, page = 1, limit = 20) => {
    setLoading(true);
    try {
      const response = await getProductsSortedByPrice(order, page, limit);
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


  // Handle Search
  const handleSearch = async (query, page, limit) => {
    setLoading(true);
    try {
      const response = await searchProducts(query, page, limit);
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



  const fetchLogic = (page) => {
    if (debouncedSearchTerm) {
      setSelectedProductCategory('Tất cả');
      setSelectedSortOrder('Default');
      handleSearch(debouncedSearchTerm, page, limit);
    } else {
      if (selectedProductCategory === "Tất cả") {
        if (selectedSortOrder === "Default") {
          fetchProducts(page, limit);
        } else {
          fetchProductsSorted(selectedSortOrder, page, limit);
        }
      } else {
        setSelectedSortOrder('Default');
        fetchProductsByCategory(selectedProductCategory, page, limit);
      }
    }
  }

  useEffect(() => {
    setCurrentPage(1);
    fetchLogic(1);
  }, [selectedProductCategory, selectedSortOrder, debouncedSearchTerm])


  // Fetch new page upon page change
  useEffect(() => {
    fetchLogic(currentPage)
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
      {loading && <LoadingOverlay />}
      <div id="ManageProducts-header">
        <h2 style={{ color: "white" }}>📦Quản lí sản phẩm</h2>
      </div>

      <div className="ManageProducts-filter">
        <div className="category">
          <h3>Phân loại:</h3>
          <select
            onChange={(e) => setSelectedProductCategory(e.target.value)}
            value={selectedProductCategory}
            disabled={searchTerm}
          >
            <option value="" disabled>
              Lọc theo phân loại
            </option>
            <option value="Tất cả">Tất cả</option>
            <option value="Đồ tươi sống">Đồ tươi sống</option>
            <option value="Thực phẩm đóng hộp">Thực phẩm đóng hộp</option>
            <option value="Đồ gia dụng">Đồ gia dụng</option>
            <option value="Khác">Khác</option>
          </select>
        </div>

        <div className="search">
          <h3>Tìm theo tên sản phẩm:</h3>
          <form>
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Nhập tên sản phẩm"
            ></input>
          </form>
        </div>

        <div className="sort">
          <h3>Giá thành:</h3>
          <select
            onChange={(e) => setSelectedSortOrder(e.target.value)}
            value={selectedSortOrder}
            disabled={searchTerm || selectedProductCategory !== 'Tất cả'}
          >
            <option value="" disabled>
              Sắp xếp theo giá
            </option>
            <option value="Default">Mặc định</option>
            <option value="ASC">Tăng dần</option>
            <option value="DESC">Giảm dần</option>
          </select>
        </div>
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
