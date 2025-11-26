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





CREATE OR ALTER PROCEDURE GetCustomersPaged (
    @page INT,
    @limit INT
)
AS
BEGIN
    SET NOCOUNT ON; -- Prevents sending rowcount message

    IF @page < 1
        SET @page = 1;
    IF @limit < 1
        SET @limit = 10;

    DECLARE @OffsetRows INT;
    DECLARE @TotalCount INT;
    DECLARE @TotalPages INT;

    -- Total Count and Total Pages
    SELECT @TotalCount = COUNT(*) FROM Customer;
    SET @TotalPages = CEILING(CAST(@TotalCount AS DECIMAL(10, 2)) / @limit);

    -- Force page if exceeds TotalPages
    IF @page > @TotalPages AND @TotalPages > 0
        SET @page = @TotalPages;
    
    SET @OffsetRows = (@page - 1) * @limit;

    ---------------------------------------------------
    -- RESULT SET 1: Customer Data
    ---------------------------------------------------
    SELECT
        C.MaKH,
        U.UserID,
        U.HoTen,
        U.GioiTinh,
        U.SoDienThoai,
        U.Email
    FROM
        Customer C
    INNER JOIN
        [User] U ON C.UserID = U.UserID
    ORDER BY
        C.MaKH -- Order by Customer ID
    OFFSET
        @OffsetRows ROWS
    FETCH NEXT
        @limit ROWS ONLY;

    ---------------------------------------------------
    -- RESULT SET 2: Pagination
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







-- SP Get San Pham by category ------------ 

CREATE OR ALTER PROCEDURE GetSanPhamByCategory (
    @Category NVARCHAR(50),
    @page INT,
    @limit INT 
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @page < 1 SET @page = 1;
    IF @limit < 1 SET @limit = 20;

    DECLARE @Offset INT = (@page - 1) * @limit;
    DECLARE @TotalCount INT;
    DECLARE @TotalPages INT;

    DECLARE @Category1 NVARCHAR(50) = N'Đồ tươi sống';
    DECLARE @Category2 NVARCHAR(50) = N'Thực phẩm đóng hộp';
    DECLARE @Category3 NVARCHAR(50) = N'Đồ gia dụng';

    --  Get Total Count---
    IF @Category IN (@Category1, @Category2, @Category3)
    BEGIN
        -- Count for specific categories
        SELECT @TotalCount = COUNT(MaSP)
        FROM [SanPham]
        WHERE LoaiSP = @Category;
    END
    ELSE IF @Category = N'Khác'
    BEGIN
        -- Count 'Khác' category
        SELECT @TotalCount = COUNT(MaSP)
        FROM [SanPham]
        WHERE LoaiSP NOT IN (@Category1, @Category2, @Category3);
    END
    ELSE
    BEGIN
        -- Fallback - count 0
        SET @TotalCount = 0;
    END

    SET @TotalPages = CEILING(CAST(@TotalCount AS DECIMAL) / @limit);
    
    -- Ensure current page does not exceed total pages
    IF @TotalCount > 0 AND @page > @TotalPages 
    BEGIN
        SET @page = @TotalPages;
        SET @Offset = (@page - 1) * @limit;
    END




    -- Return product ---
    IF @TotalCount > 0 
    BEGIN
        IF @Category IN (@Category1, @Category2, @Category3)
        BEGIN
            -- Case 1: Category match
            SELECT
                MaSP,
                TenSP,
                GiaTien,
                MoTa,
                LoaiSP
            FROM
                [SanPham]
            WHERE
                LoaiSP = @Category
            ORDER BY
                TenSP, MaSP
            OFFSET @Offset ROWS 
            FETCH NEXT @limit ROWS ONLY;
        END
        ELSE IF @Category = N'Khác'
        BEGIN
            -- Case 2: 'Khác' Category
            SELECT
                MaSP,
                TenSP,
                GiaTien,
                MoTa,
                LoaiSP
            FROM
                [SanPham]
            WHERE
                LoaiSP NOT IN (@Category1, @Category2, @Category3)
            ORDER BY
                TenSP, MaSP
            OFFSET @Offset ROWS 
            FETCH NEXT @limit ROWS ONLY;
        END
        ELSE -- return empty array for products set 
        BEGIN
            SELECT
                MaSP,
                TenSP,
                GiaTien,
                MoTa,
                LoaiSP
            FROM [SanPham]
            WHERE 1 = 0;
        END

    END
    ELSE -- return empty array for products set 
    BEGIN
        SELECT
            MaSP,
            TenSP,
            GiaTien,
            MoTa,
            LoaiSP
        FROM [SanPham]
        WHERE 1 = 0;
    END

        -- Return Paging
    SELECT
        @TotalCount AS TotalCount,
        @TotalPages AS TotalPages,
        @page AS CurrentPage,
        @limit AS [Limit];



END
GO






-- SP get SanPham sorted by GiaTien
CREATE OR ALTER PROCEDURE GetSanPhamSortedByGiaTien (
    @SortOrder VARCHAR(4),
    @page INT,
    @limit INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @page < 1 SET @page = 1;
    IF @limit < 1 SET @limit = 20;
    
    -- Ensure order valid, default ASC
    IF UPPER(@SortOrder) NOT IN ('ASC', 'DESC') 
        SET @SortOrder = 'ASC';

    DECLARE @Offset INT = (@page - 1) * @limit;
    DECLARE @TotalCount INT;
    DECLARE @TotalPages INT;

    -- Total Count ---
    SELECT @TotalCount = COUNT(MaSP) FROM [SanPham];

    -- Total page ---
    SET @TotalPages = CEILING(CAST(@TotalCount AS DECIMAL) / @limit);
    
    IF @TotalCount > 0 AND @page > @TotalPages 
    BEGIN
        SET @page = @TotalPages;
        SET @Offset = (@page - 1) * @limit;
    END

    -- Return Product Data Set ---
    IF @TotalCount > 0 
    BEGIN
        -- Use a dynamic SQL query to handle sort
        DECLARE @SQL NVARCHAR(MAX);
        
        SET @SQL = N'
        SELECT
            MaSP,
            TenSP,
            GiaTien,
            MoTa,
            LoaiSP
        FROM
            [SanPham]
        ORDER BY
            GiaTien ' + @SortOrder + N', MaSP -- Secondary sort by MaSP for stable results
        OFFSET @OffsetParam ROWS 
        FETCH NEXT @LimitParam ROWS ONLY;
        ';

        EXEC sp_executesql @SQL,
            N'@OffsetParam INT, @LimitParam INT',
            @OffsetParam = @Offset,
            @LimitParam = @limit;
    END
    ELSE -- return empty array for products set 
    BEGIN
        SELECT
            MaSP,
            TenSP,
            GiaTien,
            MoTa,
            LoaiSP
        FROM [SanPham]
        WHERE 1 = 0;
    END

    
    -- Return Paging set ---
    SELECT
        @TotalCount AS TotalCount,
        @TotalPages AS TotalPages,
        @page AS CurrentPage,
        @limit AS [Limit];


END
GO






-- Search SanPham by name

CREATE OR ALTER PROCEDURE SearchSanPham (
    @query NVARCHAR(100),
    @page INT,
    @limit INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @page < 1 SET @page = 1;
    IF @limit < 1 SET @limit = 20; 

    DECLARE @SearchPattern NVARCHAR(102) = N'%' + @query + N'%';

    DECLARE @Offset INT;
    DECLARE @TotalCount INT;
    DECLARE @TotalPages INT;

    -- Total count of return
    SELECT @TotalCount = COUNT(MaSP)
    FROM [SanPham]
    WHERE TenSP LIKE @SearchPattern;

    -- Total pages
    SET @TotalPages = CEILING(CAST(@TotalCount AS DECIMAL) / @limit);
    
    -- Recalculate offset and page if  page out of bounds
    IF @TotalCount > 0 
    BEGIN
        IF @page > @TotalPages 
        BEGIN
            SET @page = @TotalPages;
        END
    END
    ELSE 
    BEGIN
        -- If count is 0
        SET @page = 1;
        SET @TotalPages = 0;
    END

    SET @Offset = (@page - 1) * @limit;


    -- Return Product Data Set
    IF @TotalCount > 0 
    BEGIN
        SELECT
            MaSP,
            TenSP,
            GiaTien,
            MoTa,
            LoaiSP
        FROM
            [SanPham]
        WHERE
            TenSP LIKE @SearchPattern
        ORDER BY
            TenSP, MaSP
        OFFSET @Offset ROWS 
        FETCH NEXT @limit ROWS ONLY;
    END
    ELSE -- return empty array for products set 
    BEGIN
        SELECT
            MaSP,
            TenSP,
            GiaTien,
            MoTa,
            LoaiSP
        FROM [SanPham]
        WHERE 1 = 0;
    END

    -- Return pagination set
    SELECT
    @TotalCount AS TotalCount,
    @TotalPages AS TotalPages,
    @page AS CurrentPage,
    @limit AS [Limit];


END
GO










-- Function Validate Admin
CREATE OR ALTER PROCEDURE ValidateAdmin (
    @Email VARCHAR(100),
    @Password NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_UserID VARCHAR(8);
    DECLARE @v_MaAdmin VARCHAR(8) = NULL;

    -- Find UserID matching Email and Password
    SELECT 
        @v_UserID = UserID
    FROM 
        [User]
    WHERE 
        Email = @Email 
        AND Password = @Password;

    -- If UserID found, Check if admin
    IF @v_UserID IS NOT NULL
    BEGIN
        SELECT 
            @v_MaAdmin = MaAdmin
        FROM 
            Admin
        WHERE 
            UserID = @v_UserID;
    END

    -- Return admin user info
    SELECT 
        U.*, 
        A.MaAdmin
    FROM 
        [User] U
    JOIN 
        Admin A ON U.UserID = A.UserID
    WHERE
        A.MaAdmin = @v_MaAdmin
END;
GO