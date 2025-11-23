import React from "react";
import "./AdminOrderRow.css";
import { FaEdit, FaTrash } from "react-icons/fa";
import DefaultImage from "../../../assets/placeholder-image.png";

// Import utils
import { vnd } from "../../../utils/currencyUtils";
import { formatDate } from "../../../utils/dateUtils";

const AdminOrderRow = (props) => {
  const { onTopPurchased, onDelete, index } = props;

  return (
    <tr className="AdminOrderRow">
      <td>{index}</td>
      <td>
        <img src={DefaultImage} />
      </td>
      <td>
        {props.productList.map((item, index) => (
          <span key={index}>
            {/* Bold the quantity and the 'x' */}
            <b style={{ color: "hsl(87, 75%, 35%)" }}>{item.Quantity}</b>
            {"x "}
            <b>{item.ProductName}</b>
            {/* Add comma and space unless it's the last item */}
            {index < props.productList.length - 1 ? ", " : ""}
          </span>
        ))}
      </td>
      <td>{props.UserID}</td>
      <td>{vnd(props.SoTien)}</td>
      <td>{props.DiaChi}</td>
      <td>
        <span className={`status ${props.TrangThai}`}>{props.TrangThai}</span>
      </td>
      <td>{formatDate(props.NgayDatHang)}</td>
      <td>
        <button className={`action-button ${'edit'}`}>Cập nhật</button>
      </td>
    </tr>
  );
};

export default AdminOrderRow;
