import React from "react";
import "./AdminUserRow.css";
import { FaUserCircle, FaEdit, FaTrash } from "react-icons/fa";
import DefaultImage from "../../../assets/placeholder-image.png";
import { vnd } from "../../../utils/currencyUtils";

const AdminItemRow = (props) => {
  const { onTopPurchased, onDelete, index } = props;

  return (
    <tr className="AdminUserRow">
      <td id="index">{index}</td>
      <td id="user">
        <span>
          <FaUserCircle
            size={25}
            style={{'marginRight': '8px'}}
          />
          {props.HoTen}
        </span>
      </td>
      <td id="gender">{props.GioiTinh}</td>
      <td id="email">
        <span>{props.Email}</span>
      </td>
      <td id="password">{props.Password}</td>
      <td id="phone">{props.SoDienThoai}</td>
      <td id="actions">
        <button id="topPurchased" onClick={onTopPurchased}>
          Xem top sản phẩm
        </button>
      </td>
    </tr>
  );
};

export default AdminItemRow;
