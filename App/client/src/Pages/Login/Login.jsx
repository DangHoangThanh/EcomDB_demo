import "./Login.css";
import { Link, useNavigate } from "react-router-dom";


// Import APIs
import { signInAdmin } from "../../api/userService";
import { useState } from "react";

function Login() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });

  // Handle change for input fields
  const handleChange = (e) => {
    const { name, value } = e.target;

    let newValue = value;

    setFormData((prevData) => ({ ...prevData, [name]: newValue }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await signInAdmin(formData.email, formData.password);
      const adminInfo = JSON.stringify(response.adminInfo);

      localStorage.setItem('admin', adminInfo);

      alert("Đăng nhập thành công admin");
      navigate("/admin");
    } catch (error) {
      if (error.message.includes("401")) {
        alert("Sai email hoặc mật khẩu");
      } else {
        alert("Đăng nhập không thành công: ");
        console.log("Login failed: ", error.message);
      }
    }
  };

  return (
    <>
      <div className="Login-container">
        <h1>Admin đăng nhập</h1>
        <p>Đăng nhập để sử dụng admin panel</p>
        <form id="signInForm" onSubmit={handleSubmit}>
          <div>
            <label for="email"></label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              placeholder="you@email.com"
              onChange={handleChange}
            ></input>
          </div>
          <div>
            <label for="password"></label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              placeholder="********"
              onChange={handleChange}
            ></input>
          </div>
          <button type="submit" id="signInButton">
            Sign In
          </button>
        </form>
        <button onClick={() => navigate('/')}>Quay lại</button>
      </div>
    </>
  );
}

export default Login;
