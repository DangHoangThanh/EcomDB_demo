-- Retrieves a summary list of all carts associated with a user.
CREATE PROCEDURE GetMaGioHangByUserID(
    @input_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        MaGioHang,
        UserID,
        TongSoTien
    FROM
        [GioHang]
    WHERE
        UserID = @input_UserID;
END
GO

-- Procedure to retrieve all items and product details
-- in a user's shopping cart using their MaGioHang.
CREATE PROCEDURE GetCartContentByMaGioHang (
    @input_MaGioHang VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        GH.MaGioHang,
        GHI.MaSP,
        S.TenSP AS ProductName,
        S.GiaTien AS CurrentPrice,
        GHI.SoLuong AS Quantity,
        (S.GiaTien * GHI.SoLuong) AS TotalItemPrice
    FROM
        [GioHang] GH
    INNER JOIN
        [GioHangItem] GHI ON GH.MaGioHang = GHI.MaGioHang
    INNER JOIN
        [SanPham] S ON GHI.MaSP = S.MaSP
    WHERE
        GH.MaGioHang = @input_MaGioHang;
END
GO

-- Procedure to retrieve all items and product details 
-- in a user's shopping cart using their UserID.
CREATE PROCEDURE GetCartContentByUserID(
    @input_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        GH.MaGioHang,
        GHI.MaSP,
        S.TenSP AS ProductName,
        S.GiaTien AS CurrentPrice,
        GHI.SoLuong AS Quantity,
        (S.GiaTien * GHI.SoLuong) AS TotalItemPrice
    FROM
        [GioHang] GH
    INNER JOIN
        [GioHangItem] GHI ON GH.MaGioHang = GHI.MaGioHang
    INNER JOIN
        [SanPham] S ON GHI.MaSP = S.MaSP
    WHERE
        GH.UserID = @input_UserID;
END
GO











-- Retrieves a summary list of all orders placed by a user.
CREATE PROCEDURE GetOrderListByUserID(
    @input_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        MaDon,
        NgayDatHang AS OrderDate,
        SoTien AS OrderTotal,
        TrangThai AS OrderStatus,
        DiaChi AS ShippingAddress
    FROM
        [DonHang]
    WHERE
        UserID = @input_UserID
    ORDER BY
        NgayDatHang DESC;
END
GO

-- Retrieves the detailed line items and product info for an order.
CREATE PROCEDURE GetOrderContentByMaDon(
    @input_MaDon VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        DHI.MaSP,
        S.TenSP AS ProductName,
        DHI.GiaLucBan AS PriceAtOrder,
        DHI.SoLuong AS Quantity,
        (DHI.GiaLucBan * DHI.SoLuong) AS TotalLineItemPrice
    FROM
        [DonHangItem] DHI
    INNER JOIN
        [SanPham] S ON DHI.MaSP = S.MaSP
    WHERE
        DHI.MaDon = @input_MaDon
    ORDER BY
        DHI.SoLuong DESC;
END
GO










-- USP GET TOP PURCHASED ITEMS BY A USER
CREATE PROCEDURE GetTopPurchasedItems (
    @p_UserID VARCHAR(8),
    @p_Limit INT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. Validation of input parameters (Check if UserID exists)
    IF NOT EXISTS (SELECT 1 FROM [User] WHERE UserID = @p_UserID)
    BEGIN
        -- Throw an error message instead of returning a result set with an error message
        SELECT CAST('Error: UserID does not exist.' AS NVARCHAR(100)) AS ErrorMessage;
        RETURN;
    END

    -- 2. Execute the required query
    SELECT TOP (@p_Limit)
        P.TenSP, 
        SUM(DI.SoLuong) AS TotalPurchased,
        SUM(DI.SoLuong * P.GiaTien) AS TotalValue 
    FROM 
        [DonHang] DH
    INNER JOIN 
        [DonHangItem] DI ON DH.MaDon = DI.MaDon
    INNER JOIN 
        [SanPham] P ON DI.MaSP = P.MaSP 
    WHERE 
        DH.UserID = @p_UserID
    GROUP BY 
        DI.MaSP, P.TenSP 
    ORDER BY
        SUM(DI.SoLuong) DESC;
END
GO






CREATE OR ALTER PROCEDURE GetUsersPaged (
    @page INT,
    @limit INT
)
AS
BEGIN
    -- 1. Input Validation and Setup
    IF @page < 1
        SET @page = 1;
    IF @limit < 1
        SET @limit = 10;

    DECLARE @OffsetRows INT;
    DECLARE @TotalCount INT;
    DECLARE @TotalPages INT;

    -- 2. Calculate Total Products and Total Pages
    SELECT @TotalCount = COUNT(*) FROM [User];
    SET @TotalPages = CEILING(CAST(@TotalCount AS DECIMAL(10, 2)) / @limit);

    -- Force page if exceeds TotalPages
    IF @page > @TotalPages AND @TotalPages > 0
        SET @page = @TotalPages;
    
    -- Re-calculate offset after potential page adjustment
    SET @OffsetRows = (@page - 1) * @limit;

    ---------------------------------------------------
    -- RESULT SET 1: Paged Product Data
    ---------------------------------------------------
    SELECT
        *
    FROM
        [User]
    ORDER BY
        UserID
    OFFSET
        @OffsetRows ROWS
    FETCH NEXT
        @limit ROWS ONLY;

    ---------------------------------------------------
    -- RESULT SET 2: Pagination Metadata
    ---------------------------------------------------
    SELECT
        @TotalCount AS TotalCount,
        @TotalPages AS TotalPages,
        @page AS CurrentPage,
        @limit AS [Limit];

END
GO




CREATE OR ALTER PROCEDURE GetProductsPaged (
    @page INT,
    @limit INT
)
AS
BEGIN
    -- 1. Input Validation and Setup
    IF @page < 1
        SET @page = 1;
    IF @limit < 1
        SET @limit = 10;

    DECLARE @OffsetRows INT;
    DECLARE @TotalCount INT;
    DECLARE @TotalPages INT;

    -- 2. Calculate Total Products and Total Pages
    SELECT @TotalCount = COUNT(*) FROM SanPham;
    SET @TotalPages = CEILING(CAST(@TotalCount AS DECIMAL(10, 2)) / @limit);

    -- Force page if exceeds TotalPages
    IF @page > @TotalPages AND @TotalPages > 0
        SET @page = @TotalPages;
    
    -- Re-calculate offset after potential page adjustment
    SET @OffsetRows = (@page - 1) * @limit;

    ---------------------------------------------------
    -- RESULT SET 1: Paged Product Data
    ---------------------------------------------------
    SELECT
        *
    FROM
        SanPham
    ORDER BY
        MaSP
    OFFSET
        @OffsetRows ROWS
    FETCH NEXT
        @limit ROWS ONLY;

    ---------------------------------------------------
    -- RESULT SET 2: Pagination Metadata
    ---------------------------------------------------
    SELECT
        @TotalCount AS TotalCount,
        @TotalPages AS TotalPages,
        @page AS CurrentPage,
        @limit AS [Limit];

END
GO







CREATE OR ALTER PROCEDURE GetOrdersPaged (
    @page INT,
    @limit INT
)
AS
BEGIN
    -- 1. Input Validation and Setup
    IF @page < 1
        SET @page = 1;
    IF @limit < 1
        SET @limit = 10;

    DECLARE @OffsetRows INT;
    DECLARE @TotalCount INT;
    DECLARE @TotalPages INT;

    -- 2. Calculate Total Products and Total Pages
    SELECT @TotalCount = COUNT(*) FROM DonHang;
    SET @TotalPages = CEILING(CAST(@TotalCount AS DECIMAL(10, 2)) / @limit);

    -- Force page if exceeds TotalPages
    IF @page > @TotalPages AND @TotalPages > 0
        SET @page = @TotalPages;
    
    -- Re-calculate offset after potential page adjustment
    SET @OffsetRows = (@page - 1) * @limit;

    ---------------------------------------------------
    -- RESULT SET 1: Paged Product Data
    ---------------------------------------------------
    SELECT
        *
    FROM
        DonHang
    ORDER BY
        MaDon
    OFFSET
        @OffsetRows ROWS
    FETCH NEXT
        @limit ROWS ONLY;

    ---------------------------------------------------
    -- RESULT SET 2: Pagination Metadata
    ---------------------------------------------------
    SELECT
        @TotalCount AS TotalCount,
        @TotalPages AS TotalPages,
        @page AS CurrentPage,
        @limit AS [Limit];

END
GO





CREATE OR ALTER PROCEDURE GetOrderListByUserIDPaged (
    @input_UserID VARCHAR(8),
    @page INT,
    @limit INT
)
AS
BEGIN
    -- 1. Input Validation and Setup
    IF @page < 1
        SET @page = 1;
    IF @limit < 1
        SET @limit = 10;

    DECLARE @OffsetRows INT;
    DECLARE @TotalCount INT;
    DECLARE @TotalPages INT;

    -- 2. Calculate Total Products and Total Pages
    SELECT @TotalCount = COUNT(*) FROM DonHang;
    SET @TotalPages = CEILING(CAST(@TotalCount AS DECIMAL(10, 2)) / @limit);

    -- Force page if exceeds TotalPages
    IF @page > @TotalPages AND @TotalPages > 0
        SET @page = @TotalPages;
    
    -- Re-calculate offset after potential page adjustment
    SET @OffsetRows = (@page - 1) * @limit;

    ---------------------------------------------------
    -- RESULT SET 1: Paged Product Data
    ---------------------------------------------------
    SELECT
        *
    FROM
        DonHang
    WHERE
        UserID = @input_UserID
    ORDER BY
        MaDon
    OFFSET
        @OffsetRows ROWS
    FETCH NEXT
        @limit ROWS ONLY;

    ---------------------------------------------------
    -- RESULT SET 2: Pagination Metadata
    ---------------------------------------------------
    SELECT
        @TotalCount AS TotalCount,
        @TotalPages AS TotalPages,
        @page AS CurrentPage,
        @limit AS [Limit];

END
GO
