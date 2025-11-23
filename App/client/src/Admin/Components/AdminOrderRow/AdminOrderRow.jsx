import React, { useState, useEffect } from "react";
import "./AdminOrderRow.css";
import { FaEdit, FaTrash } from "react-icons/fa";
import DefaultImage from "../../../assets/placeholder-image.png";

// Import utils
import { vnd } from "../../../utils/currencyUtils";
import { formatDate } from "../../../utils/dateUtils";
import { shipStatusMap } from "../../../utils/constantsMap";

const AdminOrderRow = (props) => {
  const { index, order, onEdit } = props;

  // Dtails expanded
  const [isExpanded, setIsExpanded] = useState(false);
  const toggleDetails = () => {
    setIsExpanded(!isExpanded);
  };

  // Reset expanded state on order change
  useEffect(() => {
    setIsExpanded(false);
  }, [order]);

  return (
    <>
      <tr
        className={`AdminOrderRow ${isExpanded ? "expanded" : ""}`}
        onClick={toggleDetails}
      >
        <td>{index}</td>
        <td>
          <img src={DefaultImage} />
        </td>
        <td>
          {order.productList.map((item, index) => (
            <span key={index}>
              {/* Bold the quantity and the 'x' */}
              <b style={{ color: "hsl(87, 75%, 35%)" }}>{item.Quantity}</b>
              {"x "}
              <b>{item.ProductName}</b>
              {/* Add comma and space unless it's the last item */}
              {index < order.productList.length - 1 ? ", " : ""}
            </span>
          ))}
        </td>
        <td>{order.userInfo.HoTen}</td>
        <td>{vnd(order.SoTien)}</td>
        <td>{order.DiaChi}</td>
        <td>
          <span className={`status ${order.TrangThai}`}>{shipStatusMap[order.TrangThai]}</span>
        </td>
        <td>{formatDate(order.NgayDatHang)}</td>
        <td onClick={(event) => event.stopPropagation()}>
          <button className={`action-button ${"edit"}`} onClick={onEdit}>
            Cập nhật
          </button>
        </td>
      </tr>

      {/* Order details extra row */}
      {isExpanded && (
        <tr className="AdminOrder-details-row">
          <td style={{ background: "hsl(34, 60%, 95%)" }}></td>
          <td colSpan="8">
            <div className="AdminOrder-details-content">
              <div className="header">
                <h3>Đơn hàng {order.MaDon}</h3>
                <p style={{ display: "inline", paddingRight: "20px" }}>
                  Của khách {order.userInfo.HoTen} #{order.UserID}
                </p>
                <a style={{ color: "grey" }}>
                  Lúc {formatDate(order.NgayDatHang)}
                </a>
              </div>

              <hr></hr>

              <div className="products-list">
                {order.productList.map((item) => {
                  return (
                    <div key={item.MaSP} className="listitem">
                      <img src={DefaultImage} alt={item.ProductName} />
                      <div>
                        <h3>{item.ProductName}</h3>
                        <p>
                          Số lượng {item.Quantity} x {vnd(item.PriceAtOrder)} ={" "}
                          <b>{vnd(item.PriceAtOrder * item.Quantity)}</b>
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>

              <hr></hr>

              <div className="amount">
                <b>Tổng thu: {vnd(order.SoTien)}</b>
              </div>

              <div className="shipping-address-block">
                <h3>Giao đến:</h3>
                <b>Người nhận:</b>
                <p>Tên gọi: {order.userInfo.HoTen}</p>
                <p>Số điện thoại: {order.userInfo.SoDienThoai}</p>
                <b>Địa chỉ:</b>
                <p>{order.DiaChi}</p>
              </div>
            </div>
          </td>
        </tr>
      )}
    </>
  );
};

export default AdminOrderRow;
