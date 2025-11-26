import "./App.css";
import { BrowserRouter, Routes, Route, Navigate, Outlet } from "react-router-dom";
import PublicLayout from "./PublicLayout";
import Shop from "./Pages/Shop/Shop";
import Login from "./Pages/Login/Login";

import AdminLayout from "./Admin/AdminLayout";
import ManageUsers from "./Admin/Pages/ManageUsers/ManageUsers";
import ManageProducts from "./Admin/Pages/ManageProducts/ManageProducts";
import ManageOrders from "./Admin/Pages/ManageOrders/ManageOrders";

const ProtectedRoute = ({ children }) => {
  const isAdmin = localStorage.getItem('admin');

  if (!isAdmin) {
    // If NOT admin, redirect to login
    return <Navigate to="/login" replace />;
  }
  // If admin, render 
  return children ? children : <Outlet />;
};

function App() {
  return (
    <div>
      <BrowserRouter>
        <Routes>
          {/* === PUBLIC ROUTES === */}
          <Route path="/" element={<PublicLayout/>}>
            <Route path="/" element={<Shop/>} />
            <Route path="/login" element={<Login/>} />
          </Route>
        </Routes>
        <Routes>
          {/* === ADMIN ROUTES === */}
          <Route path="/admin" element={<ProtectedRoute><AdminLayout /></ProtectedRoute>}>
              <Route path="users" element={<ManageUsers />} />
              <Route path="products" element={<ManageProducts />} />
              <Route path="orders" element={<ManageOrders />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
