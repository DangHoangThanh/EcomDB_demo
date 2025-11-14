import { useEffect, useState } from "react";
import "./TopPurchased.css";
import DefaultImage from "../../../assets/placeholder-image.png";
import { FaUserCircle } from "react-icons/fa";
import { FiX } from "react-icons/fi";

// Import APIs
import { getTopPurchased } from "../../../api/userService";

// Import utils
import { vnd } from "../../../utils/currencyUtils";

function TopPurchased({ currentUser = null, onCancel, onSuccess }) {
  const [loading, setLoading] = useState(false);
  const [topPurchasedList, setTopPurchasedList] = useState([]);
  const limit = 6;

  const fetchTopPurchased = async (UserID = null, limit = 5) => {
    setLoading(true);
    try {
      const response = await getTopPurchased(UserID, limit);
      const resTopPurchased = response;

      setTopPurchasedList(resTopPurchased);
    } catch (error) {
      console.log(error);
      alert("Fetch users failed");
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchTopPurchased(currentUser.UserID, limit);
  }, [currentUser]);

  // Form container
  return (
    <div className="TopPurchased-container">
      <header>
        <div id="title" style={{ display: "flex", alignItems: "center" }}>
          <FaUserCircle size={30} style={{ marginRight: "10px" }} />
          {currentUser.HoTen}
        </div>
        <div id="subTitle">Top {limit} sản phẩm mua nhiều nhất</div>
      </header>
      {/* Actual form */}
      {topPurchasedList && topPurchasedList.length > 0 ? (
      <table id="table">
        <thead>
          <tr>
            <th className="index">#</th>
            <th>Hình ảnh</th>
            <th>Tên sản phẩm</th>
            <th>Tổng số lượng mua</th>
            <th>Tổng giá trị mua</th>
          </tr>
        </thead>
        <tbody>
          
          {topPurchasedList.map((item, i) => {
            return (
              <tr className="TopPurchasedRow">
                <td id="index">{i+1}</td>
                <td id="image" size={40}>
                  <img src={DefaultImage} alt={"Image for " + item.TenSP} />
                </td>
                <td id="name">{item.TenSP}</td>
                <td id="count">{item.TotalPurchased}</td>
                <td id="price">{vnd(item.TotalValue)}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
      ) : (
        <div> Người dùng chưa mua sản phẩm nào </div>
      )}

      <button id="TopPurchased-cancel" onClick={onCancel}>
        <FiX />
        Hủy
      </button>
    </div>
  );
}

export default TopPurchased;
