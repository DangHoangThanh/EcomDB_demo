import "./ManageUsers.css";
import React, { useState, useEffect } from "react";

// import components
import AdminUserRow from "../../Components/AdminUserRow/AdminUserRow";
import TopPurchased from "../../Components/TopPurchased/TopPurchased";

// Import APIs
import { getAllUsers } from "../../../api/userService";


function ManageUsers() {
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [users, setUsers] = useState([]);
  const [totalCount, setTotalCount] = useState(0);
  const limit = 10;

  // Fetch users method
  const fetchUsers = async (page = 1, limit = 20) => {
    setLoading(true);
    try {
      const response = await getAllUsers(page, limit);
      const resUsers = response.users;
      const resPagination = response.pagination;
      
      setUsers(resUsers);
      setTotalCount(resPagination.TotalCount);
      setTotalPages(resPagination.TotalPages);
    } catch (error) {
      console.log(error);
      alert("Fetch users failed");
    }
    setLoading(false);
  };

  // Fetch new page upon page change
  useEffect(() => {
    fetchUsers(currentPage, limit);
  }, [currentPage]);

  // State Form
  const [isFormVisible, setIsFormVisible] = useState(false);
  const [CurrentUser, setCurrentUser] = useState(null);

  // Open form with mode "add", "edit", "delete"
  const openForm = (mode, currentUser = null) => {
    setCurrentUser(currentUser);
    setIsFormVisible(true);
  };

  return (
    <div className="ManageUsers-container">
      <div id="ManageUsers-header">
        <h2 style={{ color: "white" }}>👤Quản lí Người dùng</h2>
      </div>

      <div className="admin-users-list">
        <header>Danh sách Người dùng</header>

        <div>Tổng cộng {totalCount} người dùng</div>


        <table id="table">
          <thead>
            <tr>
              <th className="index">#</th>
              <th>Người dùng</th>
              <th>Giới tính</th>
              <th>Email</th>
              <th>Mật khẩu</th>
              <th>Số điện thoại</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {users.map((item, i) => {
              const index = i + 1 + (currentPage - 1) * limit;
              return (
                <AdminUserRow
                  key={i}
                  index={index}
                  {...item}
                  onTopPurchased={() => openForm("edit", item)}
                  onDelete={() => openForm("delete", item)}
                />
              );
            })}
          </tbody>
        </table>

        {/* Paging for users */}
        <div className="ManageUsers-paging">
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


      {/* Conditional Rendering of Form */}
      {isFormVisible && (
        <div id="TopPurchasedForm-overlay">
          <TopPurchased
            currentUser={CurrentUser}
            onCancel={() => setIsFormVisible(false)} // Pass a function to close the form
          />
        </div>
      )}
    </div>
  );
}

export default ManageUsers;
