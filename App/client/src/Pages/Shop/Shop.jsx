import "./Shop.css";
import { useContext } from "react";
import { Link, useNavigate } from "react-router-dom";

function Shop() {
  const navigate = useNavigate();
  const admin = JSON.parse(localStorage.getItem("admin"));

  const handleLogout = () => {
    localStorage.removeItem("admin");
    window.dispatchEvent(new Event("auth-changed"));

    navigate("/login");
  };

  return (
    <div className="Shop-container">
      <div className="Shop-content">
        <div>Hello, Bạn đang ở landing page cho shop</div>
        {admin ? (
          <>
            <p>Logged in as {admin.HoTen}</p>
            <Link to="/admin">
              <button>Đi đến trang Admin</button>
            </Link>
            <button onClick={handleLogout}>Đăng xuất</button>
          </>
        ) : (
          <Link to="/login">
            <button>Đăng nhập</button>
          </Link>
        )}
      </div>
    </div>
  );
}

export default Shop;
