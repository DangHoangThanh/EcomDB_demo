import React, { useState, useEffect } from "react";
import "./AdminUserRow.css";
import { FaUserCircle, FaEdit, FaTrash } from "react-icons/fa";
import DefaultImage from "../../../assets/placeholder-image.png";

// Import Utils
import { vnd } from "../../../utils/currencyUtils";
import { genderMap } from "../../../utils/constantsMap";

const AdminItemRow = (props) => {
  const { user, onTopPurchased, index } = props;
  const [passwordVisible, setPasswordVisible] = useState(false);

  const togglePasswordVisible = () => {
    setPasswordVisible(!passwordVisible);
  }

  useEffect(() => {
    setPasswordVisible(false);
  },[user])

  return (
    <tr className="AdminUserRow">
      <td id="index">{index}</td>
      <td id="user">
        <span>
          <FaUserCircle
            size={25}
            style={{'marginRight': '8px'}}
          />
          {user.HoTen}
        </span>
      </td>
      <td>
        <span className={`gender ${user.GioiTinh}`}>
          {genderMap[user.GioiTinh]}
        </span>
      </td>
      <td>{user.SoDienThoai}</td>
      <td>
        <span>{user.Email}</span>
      </td>
      {/* <td onClick={() => togglePasswordVisible()}>
        <span className={`password ${passwordVisible? 'visible': ''}`}>
          {passwordVisible ? (
            
            <code>{user.Password}</code>
          ) : (
            <b> Xem mật khẩu</b>
          )
          }
        </span>
      </td> */}
      <td>
        <button className={`action-button ${'topPurchased'}`} onClick={onTopPurchased}>
          Mua nhiều nhất
        </button>
      </td>
    </tr>
  );
};

export default AdminItemRow;
