import "./OrderForm.css"
import { FaArrowLeft } from "react-icons/fa";

// Import utils
import { shipStatusMap } from "../../../utils/constantsMap";

function OrderForm(props) {
  const { order, onEdit, onRefund, onCancel } = props;

  return (
    <div className="OrderForm-container">
      <header>
        <h2>Cập nhật đơn hàng:</h2>
        <p>Người dùng ID: {order.UserID || "No UserID"}</p>
        <p>Mã đơn: {order.MaDon || "No MaDon"}</p>
        <div className={`status ${order.TrangThai}`}>
          {shipStatusMap[order.TrangThai]}
        </div>
      </header>
      <h2>Trạng thái mới:</h2>
      <div className="OrderForm-options">
        <button
          className={`status ${"Pending"}`}
          onClick={() => onEdit("Pending")}
          disabled={true}
        >
          Chờ xác nhận
        </button>
        <button
          className={`status ${"Processing"}`}
          onClick={() => onEdit("Processing")}
          disabled={order.TrangThai !== 'Pending'}
        >
          Đang xử lý
        </button>
        <button
          className={`status ${"Shipping"}`}
          onClick={() => onEdit("Shipping")}
          disabled={order.TrangThai !== 'Processing'}
        >
          Đang vận chuyển
        </button>
        <button
          className={`status ${"Delivered"}`}
          onClick={() => onEdit("Delivered")}
          disabled={order.TrangThai !== 'Shipping'}
        >
          Giao thành công
        </button>

        <button
          className={`status ${"Cancelled"}`}
          onClick={() => onEdit("Cancelled")}
          disabled={!['Pending', 'Processing'].includes(order.TrangThai)}
        >
          Hủy đơn
        </button>

      </div>
      <button id="OrderForm-cancel" onClick={onCancel}>
        <FaArrowLeft fill="white" style={{ marginRight: "5px" }} />
        Quay lại
      </button>
    </div>
  );
}

export default OrderForm;