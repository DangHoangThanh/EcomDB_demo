import "./ManageOrders.css";
import React, { useState, useEffect } from "react";

// Import components
import AdminOrderRow from "../../Components/AdminOrderRow/AdminOrderRow";

// Import APIs
import { getAllOrders } from "../../../api/orderService";


function ManageOrders() {
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [orders, setOrders] = useState([]);
  const [totalCount, setTotalCount] = useState(0);
  const limit = 10;

  // Fetch users method
  const fetchOrders = async (page = 1, limit = 20) => {
    setLoading(true);
    try {
      const response = await getAllOrders(page, limit);
      const resOrders = response.orders;
      const resPagination = response.pagination;
      
      setOrders(resOrders);
      setTotalCount(resPagination.TotalCount);
      setTotalPages(resPagination.TotalPages);
    } catch (error) {
      console.log(error);
      alert("Fetch Orders failed");
    }
    setLoading(false);
  };

  // Fetch new page upon page change
  useEffect(() => {
    fetchOrders(currentPage, limit);
  }, [currentPage]);


  return (
    <div className="ManageOrders-container">
      <div id="ManageOrders-header">
        <h2 style={{ color: "white" }}>📦Quản lí đơn hàng</h2>
      </div>

      <div className="ManageOrders-table-container">
        <header>Danh sách đơn hàng</header>

        <div>Tổng cộng {totalCount} đơn hàng</div>


        <table>
          <thead>
            <tr>
              <th className="index">#</th>
              <th>Đơn hàng</th>
              <th>Nội dung</th>
              <th>Khách hàng</th>
              <th>Số tiền</th>
              <th>Địa chỉ</th>
              <th>Trạng thái</th>
              <th>Đặt hàng lúc</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {orders.map((item, i) => {
              const index = i + 1 + (currentPage - 1) * limit;
              return (
                <AdminOrderRow
                  key={i}
                  index={index}
                  {...item}
                />
              );
            })}
          </tbody>
        </table>

        {/* Paging for users */}
        <div className="ManageOrders-paging">
          <button
            onClick={() => setCurrentPage(currentPage - 1)}
            disabled={currentPage <= 1 || loading}
          >
            Trước
          </button>

          <span>
            Trang {currentPage} trên {totalPages}
          </span>

          <button
            onClick={() => setCurrentPage(currentPage + 1)}
            disabled={currentPage >= totalPages || loading}
          >
            Sau
          </button>
        </div>
      </div>


    </div>
  );
}

export default ManageOrders;
