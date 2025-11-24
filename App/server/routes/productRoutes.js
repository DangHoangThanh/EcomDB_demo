const express = require("express");
const router = express.Router();
const sql = require("mssql");

// import dbConfig
const dbConfig = require("../dbConfig");

// (GET)/product/products/
// Return products with paging
router.get("/products/", async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();

    request.input("page", sql.Int, page);
    request.input("limit", sql.Int, limit);

    const result = await request.execute("GetProductsPaged");

    const products = result.recordsets[0];
    const pagination = result.recordsets[1][0];

    const reponseContent = {
      products: products,
      pagination: pagination,
    };

    return res.json(reponseContent);
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .send({ message: "Error executing get products paged." });
  }
});

// (GET)/product/products/category
// get products by category paged
router.get("/products/category", async (req, res) => {
  const { category } = req.query;
  let page = parseInt(req.query.page, 10) || 1;
  let limit = parseInt(req.query.limit, 10) || 20;

  if (!category) {
    return res.status(400).json({ error: "Category parameter is required." });
  }

  if (page < 1) page = 1;
  if (limit < 1) limit = 1;

  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();

    // Setup input
    request.input("Category", sql.NVarChar(50), category);
    request.input("page", sql.Int, page);
    request.input("limit", sql.Int, limit);

    const result = await request.execute("GetSanPhamByCategory");

    // Return 2 sets: products and paging
    const products = result.recordsets[0] || [];
    const pagination =
      result.recordsets[1] && result.recordsets[1].length > 0
        ? result.recordsets[1][0]
        : { TotalCount: 0, TotalPages: 0, CurrentPage: page, Limit: limit };

    res.json({
      products: products,
      pagination: pagination,
    });
  } catch (err) {
    console.error("SQL Error during SP execution:", err.message);
    res.status(500).json({
      error: "Failed to retrieve products from database.",
      details: err.message,
    });
  }
});

// (GET)/product/products/sorted
// get products sorted by GiaTien
router.get("/products/sorted", async (req, res) => {
  let sortOrder = req.query.order ? req.query.order.toUpperCase() : "ASC";
  let page = parseInt(req.query.page, 10) || 1;
  let limit = parseInt(req.query.limit, 10) || 20;

  if (sortOrder !== "ASC" && sortOrder !== "DESC") {
    sortOrder = "ASC";
  }

  if (page < 1) page = 1;
  if (limit < 1) limit = 1;

  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();

    request.input("SortOrder", sql.VarChar(4), sortOrder);
    request.input("page", sql.Int, page);
    request.input("limit", sql.Int, limit);

    const result = await request.execute("GetSanPhamSortedByGiaTien");

    // Return 2 sets: products and pagination
    const products = result.recordsets[0] || [];
    const pagination =
      result.recordsets[1] && result.recordsets[1].length > 0
        ? result.recordsets[1][0]
        : { TotalCount: 0, TotalPages: 0, CurrentPage: page, Limit: limit };

    res.json({
      products: products,
      pagination: pagination,
    });
  } catch (err) {
    console.error("SQL Error during sorted product execution:", err.message);
    res.status(500).json({
      error: "Failed to retrieve sorted products from database.",
      details: err.message,
    });
  }
});




// (GET)/product/products/search
// search products by name
router.get("/products/search", async (req, res) => {
  const { query } = req.query;
  let page = parseInt(req.query.page, 10) || 1;
  let limit = parseInt(req.query.limit, 10) || 20;

  if (!query || query.trim() === "") {
    return res
      .status(400)
      .json({ error: "Search query parameter (q) is required." });
  }

  // Ensure numeric values are positive
  if (page < 1) page = 1;
  if (limit < 1) limit = 1;

  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();

    request.input("query", sql.NVarChar(100), query.trim());
    request.input("page", sql.Int, page);
    request.input("limit", sql.Int, limit);

    const result = await request.execute("SearchSanPham");

    // Return 2 sets
    const products = result.recordsets[0] || [];
    const pagination =
      result.recordsets[1] && result.recordsets[1].length > 0
        ? result.recordsets[1][0]
        : { TotalCount: 0, TotalPages: 0, CurrentPage: page, Limit: limit };

    res.json({
      products: products,
      pagination: pagination,
    });
  } catch (err) {
    console.error("SQL Error during product search execution:", err.message);
    res.status(500).json({
      error: "Failed to execute product search.",
      details: err.message,
    });
  }
});




// (GET)/:MaSP
// Return single product
router.get("/:MaSP", async (req, res) => {
  const MaSP = req.params.MaSP;
  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();

    request.input("MaSP", sql.VarChar, MaSP);
    const result = await request.query(
      "SELECT * FROM [SanPham] WHERE MaSP = @MaSP"
    );

    return res.json(result.recordsets[0]);
  } catch (error) {
    console.log(error);
    return res
      .status(500)
      .send({ message: "Error executing get product query." });
  }
});

// (POST) /new - Thêm sản phẩm mới
// Body yêu cầu: TenSP, GiaTien, MoTa, LoaiSP
router.post("/new", async (req, res) => {
  const { TenSP, GiaTien, MoTa, LoaiSP } = req.body;

  if (!TenSP || !GiaTien || !LoaiSP) {
    return res.status(400).json({
      message: "Thiếu các trường bắt buộc: TenSP, GiaTien, LoaiSP.",
    });
  }

  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();

    // Gán giá trị cho các tham số đầu vào của Stored Procedure
    request.input("TenSP", sql.NVarChar(150), TenSP);
    request.input("GiaTien", sql.Decimal(12, 2), GiaTien);
    request.input("MoTa", sql.NVarChar(1000), MoTa);
    request.input("LoaiSP", sql.NVarChar(30), LoaiSP);

    const result = await request.execute("InsertSanPham");

    // Xử lý kết quả trả về từ lệnh SELECT trong SP

    if (result.recordset && result.recordset.length > 0) {
      const newMaSP = result.recordset[0].MaSP_Moi;

      // Chèn thành công
      res.status(201).json({
        message: `Thêm sản phẩm thành công!`,
        MaSP_Moi: newMaSP,
        data: { TenSP, GiaTien, MoTa, LoaiSP },
      });
    } else {
      res.status(500).json({
        message: "Thêm sản phẩm thành công nhưng không lấy được Mã SP mới.",
      });
    }
  } catch (err) {
    console.error("Lỗi khi thêm sản phẩm mới:", err.message);

    res.status(500).json({
      message: "Lỗi máy chủ nội bộ trong quá trình thêm sản phẩm.",
      error: err.message,
    });
  }
});

// (PUT)/:MaSP/edit
// Edit product
router.put("/:MaSP/edit", async (req, res) => {
  const { MaSP } = req.params;

  const { TenSP, GiaTien, MoTa, LoaiSP } = req.body;

  if (!TenSP || !GiaTien || !LoaiSP) {
    return res.status(400).json({
      message: "Thiếu các trường bắt buộc: TenSP, GiaTien, LoaiSP.",
    });
  }

  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();

    // Gán input cho SP
    request.input("MaSP", sql.VarChar(8), MaSP);
    request.input("TenSP", sql.NVarChar(150), TenSP);
    request.input("GiaTien", sql.Decimal(12, 2), GiaTien);
    request.input("MoTa", sql.NVarChar(1000), MoTa);
    request.input("LoaiSP", sql.NVarChar(30), LoaiSP);

    const result = await request.execute("EditSanPham");

    // Lấy return code
    const returnValue = result.returnValue;

    if (returnValue === 1) {
      // Cập nhật thành công (Return 1)
      res.status(200).json({
        message: `Cập nhật sản phẩm có mã ${MaSP} thành công.`,
        updatedProduct: { MaSP, TenSP, GiaTien, MoTa, LoaiSP },
      });
    } else if (returnValue === 0) {
      // Sản phẩm không tồn tại (Return 0 sau khi RAISERROR)
      res.status(404).json({
        message: `Lỗi: Không tìm thấy sản phẩm có mã ${MaSP} để cập nhật. (Mã lỗi SP: 0)`,
      });
    } else {
      res.status(500).json({
        message: `Lỗi không xác định khi gọi Stored Procedure. Giá trị trả về: ${returnValue}`,
      });
    }
  } catch (err) {
    console.error("Lỗi khi cập nhật sản phẩm:", err.message);

    if (err.message.includes("Lỗi: Không tìm thấy sản phẩm")) {
      return res.status(404).json({ message: err.message });
    }

    // Lỗi chung
    res.status(500).json({
      message: "Lỗi máy chủ nội bộ trong quá trình cập nhật sản phẩm.",
      error: err.message,
    });
  }
});

// (DELETE)/:MaSP
// Return single product
router.delete("/:MaSP", async (req, res) => {
  const MaSP = req.params.MaSP;
  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();

    request.input("MaSP", sql.VarChar, MaSP);
    const result = await request.execute("DeleteSanPham");

    const returnValue = result.returnValue;

    if (returnValue === 1) {
      res.status(200).json({
        success: true,
        message: `Đã xóa thành công sản phẩm có mã: ${MaSP}`,
      });
    } else {
      res.status(404).json({
        success: false,
        message: `Xóa thất bại. Không tìm thấy hoặc xảy ra lỗi khi xóa sản phẩm có mã: ${MaSP}`,
      });
    }
  } catch (error) {
    console.log(error);
    return res.status(500).send({ message: "Error executing delete product." });
  }
});

module.exports = router;
