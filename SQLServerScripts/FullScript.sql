

-- ======================================
-- USER RELATED SCRIPTS
-- ======================================


-- ======================================
-- USER RELATED SCRIPTS
-- ======================================


-- ======================================
-- USER RELATED SCRIPTS
-- ======================================

CREATE TABLE [User] (
    UserID VARCHAR(8) PRIMARY KEY, 
    Password NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10) NOT NULL, 
    SoDienThoai VARCHAR(20) UNIQUE, 
    Email VARCHAR(100) NOT NULL UNIQUE,
    
    -- Constraint to enforce 'Nam' or 'Nu' for GioiTinh
    CONSTRAINT CK_User_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nữ'))
);
GO


-- Sequence object to manage the auto-incrementing number part of UserID
CREATE SEQUENCE UserID_Seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    CACHE 50;
GO




-- Insert User

CREATE PROCEDURE InsertUser (
    @p_Password NVARCHAR(255),
    @p_HoTen NVARCHAR(100),
    @p_GioiTinh NVARCHAR(10),
    @p_SoDienThoai VARCHAR(20),
    @p_Email VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON; -- Prevents sending rowcount message

    DECLARE @v_NextValue INT;
    DECLARE @v_NewUserID VARCHAR(8);

    -- 1. Get the next value from the sequence
    SET @v_NextValue = NEXT VALUE FOR UserID_Seq;
    
    -- 2. Format new ID (prefix 'USE' + 5 digits)
    SET @v_NewUserID = 'USE' + FORMAT(@v_NextValue, 'D5'); 

    -- 3. Insert the new user record
    INSERT INTO [User] (UserID, Password, HoTen, GioiTinh, SoDienThoai, Email)
    VALUES (@v_NewUserID, @p_Password, @p_HoTen, @p_GioiTinh, @p_SoDienThoai, @p_Email);
    
    -- Return generated UserID
    SELECT @v_NewUserID AS ReturnNewUserID;
END;
GO






CREATE TABLE Customer (
    MaKH VARCHAR(8) PRIMARY KEY,
    UserID VARCHAR(8) NOT NULL UNIQUE,
    
    -- Foreign Key
    CONSTRAINT FK_Customer_User FOREIGN KEY (UserID)
    REFERENCES [User](UserID)
    ON DELETE CASCADE -- If a user is deleted, their customer record is also deleted
);
GO



CREATE TABLE Admin (
    MaAdmin VARCHAR(8) PRIMARY KEY,
    UserID VARCHAR(8) NOT NULL UNIQUE,
    CCCD VARCHAR(20) NOT NULL UNIQUE,
    
    -- Foreign Key
    CONSTRAINT FK_Admin_User FOREIGN KEY (UserID)
    REFERENCES [User](UserID)
    ON DELETE CASCADE -- If a user is deleted, their admin record is also deleted
);
GO



-- Sequence for MaKH
CREATE SEQUENCE CustomerID_Seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    CACHE 50;
GO

-- Sequence for MaAdmin
CREATE SEQUENCE AdminID_Seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    CACHE 50;
GO




CREATE PROCEDURE RegisterCustomer (
    @UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_NextValue INT;
    DECLARE @v_NewMaKH VARCHAR(8);

    -- 1. Get the next value from the sequence
    SET @v_NextValue = NEXT VALUE FOR CustomerID_Seq;
    
    -- 2. Format new ID (prefix 'CUS' + 5 digits)
    SET @v_NewMaKH = 'CUS' + FORMAT(@v_NextValue, 'D5'); 

    -- 3. Insert the new customer record
    INSERT INTO Customer (MaKH, UserID)
    VALUES (@v_NewMaKH, @UserID);
    
    -- Return generated MaKH
    SELECT @v_NewMaKH AS ReturnNewMaKH;
END;
GO




CREATE PROCEDURE RegisterAdmin (
    @UserID VARCHAR(8),
    @CCCD VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_NextValue INT;
    DECLARE @v_NewMaAdmin VARCHAR(8);

    -- 1. Get the next value from the sequence
    SET @v_NextValue = NEXT VALUE FOR AdminID_Seq;
    
    -- 2. Format new ID (prefix 'ADM' + 5 digits)
    SET @v_NewMaAdmin = 'ADM' + FORMAT(@v_NextValue, 'D5'); 

    -- 3. Insert the new admin record
    INSERT INTO Admin (MaAdmin, UserID, CCCD)
    VALUES (@v_NewMaAdmin, @UserID, @CCCD);
    
    -- Return generated MaAdmin
    SELECT @v_NewMaAdmin AS ReturnNewMaAdmin;
END;
GO






-- Insert sample data

EXEC InsertUser N'hashed_pass_a', N'Nguyễn Văn A', N'Nam', '0901234567', 'nguyenvana@email.com';
EXEC InsertUser N'hashed_pass_b', N'Trần Thị B', N'Nữ', '0917654321', 'tranthib@email.com';
EXEC InsertUser N'hashed_pass_c', N'Lê Minh Cảnh', N'Nam', '0988777666', 'leminhc@email.com';
EXEC InsertUser N'hashed_pass_d', N'Phạm Thu Hằng', N'Nữ', '0399888777', 'phthuha@email.com';
EXEC InsertUser N'hashed_pass_e', N'Vũ Đình Dũng', N'Nam', '0861112222', 'vudung@email.com';

EXEC InsertUser N'hash_f', N'Hoàng Văn Phúc', N'Nam', '0812345678', 'hoangf@email.com';
EXEC InsertUser N'hash_g', N'Ngô Thị Giang', N'Nữ', '0937654321', 'ngog@email.com';
EXEC InsertUser N'hash_h', N'Đào Quốc Hùng', N'Nam', '0978888777', 'daoh@email.com';
EXEC InsertUser N'hash_i', N'Lâm Khánh Linh', N'Nữ', '0389999000', 'lami@email.com';
EXEC InsertUser N'hash_j', N'Mai Đình Khoa', N'Nam', '0891113333', 'maij@email.com';
EXEC InsertUser N'hash_k', N'Phan Thị Kim', N'Nữ', '0945556666', 'phank@email.com';
EXEC InsertUser N'hash_l', N'Trần Bá Lộc', N'Nam', '0923456789', 'tranl@email.com';

-- 4 Admins
EXEC InsertUser N'vom', N'Võ Thu Minh', N'Nữ', '0367890123', 'vom@email.com';
EXEC InsertUser N'buin', N'Bùi Đức Nhân', N'Nam', '0778889990', 'buin@email.com';
EXEC InsertUser N'doanh', N'Đỗ Lan Oanh', N'Nữ', '0961234567', 'doanh@email.com';
EXEC InsertUser N'admin', N'Nguyễn Admin', N'Nam', '0964799567', 'NgAdmin@email.com';


-- Register Sample Customers (Users USE00001 to USE00012) ---

EXEC RegisterCustomer 'USE00001';
EXEC RegisterCustomer 'USE00002';
EXEC RegisterCustomer 'USE00003';
EXEC RegisterCustomer 'USE00004';
EXEC RegisterCustomer 'USE00005';
EXEC RegisterCustomer 'USE00006';
EXEC RegisterCustomer 'USE00007';
EXEC RegisterCustomer 'USE00008';
EXEC RegisterCustomer 'USE00009';
EXEC RegisterCustomer 'USE00010';
EXEC RegisterCustomer 'USE00011';
EXEC RegisterCustomer 'USE00012';

-- Register Sample Admins (Users USE00013 to USE00015) ---
EXEC RegisterAdmin 'USE00013', '001122334455';
EXEC RegisterAdmin 'USE00014', '002233445566';
EXEC RegisterAdmin 'USE00015', '003344556677';
EXEC RegisterAdmin 'USE00016', '002343556677';






SELECT * FROM [User];
SELECT * FROM [Customer];
SELECT * FROM [Admin];
GO








-- ======================================
-- PRODUCTS RELATED SCRIPTS
-- ======================================


-- ======================================
-- PRODUCTS RELATED SCRIPTS
-- ======================================


-- ======================================
-- PRODUCTS RELATED SCRIPTS
-- ======================================

-- ==========================================
-- BẢNG CHA: SANPHAM (SQL SERVER VERSION)
-- ==========================================

CREATE TABLE SanPham (
    MaSP VARCHAR(8) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL UNIQUE,
    GiaTien DECIMAL(10,2) CHECK (GiaTien > 0),
    MoTa NVARCHAR(255),
    LoaiSP NVARCHAR(50) DEFAULT N'Chưa phân loại'
);
GO

-- TẠO BẢNG RIÊNG ĐỂ THÊM PREFIX
create table sequenceCounter (
	sq_name varchar(50) primary key,
	id int not null,
);
insert into sequenceCounter (sq_name, id)
values ('MaSP', 0);
GO
-- ==========================================
-- PROCEDURE InsertSanPham
-- PREFIX: PRO000001, PRO000002...
-- ==========================================

CREATE OR ALTER PROCEDURE InsertSanPham
    @TenSP      NVARCHAR(150),
    @GiaTien    DECIMAL(12,2),
    @MoTa       NVARCHAR(1000) = NULL,
    @LoaiSP     NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_nextV INT;
    DECLARE @v_newID VARCHAR(8);

    -- Tăng giá trị trong bảng sequenceCounter và lấy giá trị mới
    UPDATE dbo.sequenceCounter
    SET id = id + 1
    WHERE sq_name = 'MaSP';

    -- Lấy giá trị vừa mới tăng
    SELECT @v_nextV = id
    FROM dbo.sequenceCounter
    WHERE sq_name = 'MaSP';

    -- Tạo mã đúng định dạng PRO000001
    SET @v_newID = 'PRO' + RIGHT('00000' + CAST(@v_nextV AS VARCHAR(5)), 5);
    -- Ví dụ: @v_nextV = 1  → PRO000001
    --         @v_nextV = 23 → PRO000023

    -- Chèn vào bảng SanPham
    INSERT INTO SanPham (MaSP, TenSP, GiaTien, MoTa, LoaiSP)
    VALUES (@v_newID, @TenSP, @GiaTien, @MoTa, @LoaiSP);

    PRINT 'Thêm sản phẩm thành công! Mã SP: ' + @v_newID;
    SELECT @v_newID AS MaSP_Moi;
END
GO

-- ==========================================
-- CÁC BẢNG CON
-- ==========================================
CREATE TABLE ThucPhamDongHop (
    MaSP VARCHAR(8) PRIMARY KEY,
    ThanhPhan VARCHAR(255),
    HanSuDung DATE,
    NhaSanXuat VARCHAR(100),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)
GO

CREATE TABLE DoGiaDung (
    MaSP VARCHAR(8) PRIMARY KEY,
    ChatLieu VARCHAR(100),
    BaoHanh VARCHAR(50) DEFAULT '12 tháng',
    ThuongHieu VARCHAR(100),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)
GO

CREATE TABLE DoTuoiSong (
    MaSP VARCHAR(8) PRIMARY KEY,
    NhietDoBaoQuan DECIMAL(5,2),
    XuatXu VARCHAR(100),
    NgayNhap DATE,
    HanSuDung DATE,
    CHECK (HanSuDung > NgayNhap),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)
GO
-- ==========================================
-- 3 PROCEDURE THÊM SẢN PHẨM THEO LOẠI
-- ==========================================

-- PROCEDURE 1: ĐỒ TƯƠI SỐNG
CREATE OR ALTER PROCEDURE Add_DoTuoiSong
    @TenSP      NVARCHAR(100),
    @GiaTien    DECIMAL(10,2),
    @MoTa       NVARCHAR(255) = NULL,
    @NhietDo    DECIMAL(5,2),
    @XuatXu     NVARCHAR(100),
    @HanSuDung  DATE               
AS
BEGIN
    SET NOCOUNT ON;

    IF @GiaTien <= 0
    BEGIN
        RAISERROR(N'Giá tiền phải lớn hơn 0!', 16, 1);
        RETURN;
    END

    IF @HanSuDung < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR(N'Hạn sử dụng không được nhỏ hơn ngày hiện tại!', 16, 1);
        RETURN;
    END

    DECLARE @NewMaSP VARCHAR(10);

    -- Sinh mã PRO000001, PRO000002...
    UPDATE dbo.sequenceCounter SET id = id + 1 WHERE sq_name = 'MaSP';
    SELECT @NewMaSP = 'PRO' + RIGHT('00000' + CAST(id AS VARCHAR(5)), 5)
    FROM dbo.sequenceCounter WHERE sq_name = 'MaSP';

    -- Thêm vào bảng cha
    INSERT INTO SanPham (MaSP, TenSP, GiaTien, MoTa, LoaiSP)
    VALUES (@NewMaSP, @TenSP, @GiaTien, @MoTa, N'Đồ tươi sống');

    -- Thêm vào bảng con
    INSERT INTO DoTuoiSong (MaSP, NhietDoBaoQuan, XuatXu, NgayNhap, HanSuDung)
    VALUES (@NewMaSP, @NhietDo, @XuatXu, CAST(GETDATE() AS DATE), @HanSuDung);

    PRINT N'Thêm đồ tươi sống thành công! Mã SP: ' + @NewMaSP;
END
GO

-- PROCEDURE 2: ĐỒ GIA DỤNG
CREATE OR ALTER PROCEDURE Add_DoGiaDung
    @TenSP       NVARCHAR(100),
    @GiaTien     DECIMAL(10,2),
    @MoTa        NVARCHAR(255) = NULL,
    @ChatLieu    NVARCHAR(100),
    @BaoHanh     NVARCHAR(50) = N'12 tháng',
    @ThuongHieu  NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF @GiaTien <= 0
    BEGIN
        RAISERROR(N'Giá tiền phải lớn hơn 0!', 16, 1);
        RETURN;
    END

    DECLARE @NewMaSP VARCHAR(10);

    UPDATE dbo.sequenceCounter SET id = id + 1 WHERE sq_name = 'MaSP';
    SELECT @NewMaSP = 'PRO' + RIGHT('00000' + CAST(id AS VARCHAR(5)), 5)
    FROM dbo.sequenceCounter WHERE sq_name = 'MaSP';

    INSERT INTO SanPham (MaSP, TenSP, GiaTien, MoTa, LoaiSP)
    VALUES (@NewMaSP, @TenSP, @GiaTien, @MoTa, N'Đồ gia dụng');

    INSERT INTO DoGiaDung (MaSP, ChatLieu, BaoHanh, ThuongHieu)
    VALUES (@NewMaSP, @ChatLieu, @BaoHanh, @ThuongHieu);

    PRINT N'Thêm đồ gia dụng thành công! Mã SP: ' + @NewMaSP;
END
GO

-- PROCEDURE 3: THỰC PHẨM ĐÓNG HỘP
CREATE OR ALTER PROCEDURE Add_ThucPhamDongHop
    @TenSP      NVARCHAR(100),
    @GiaTien    DECIMAL(10,2),
    @MoTa       NVARCHAR(255) = NULL,
    @ThanhPhan  NVARCHAR(255),
    @NhaSX      NVARCHAR(100),
    @HanSuDung  DATE                
AS
BEGIN
    SET NOCOUNT ON;

    IF @GiaTien <= 0
    BEGIN
        RAISERROR(N'Giá tiền phải lớn hơn 0!', 16, 1);
        RETURN;
    END

    IF @HanSuDung < DATEADD(MONTH, 3, CAST(GETDATE() AS DATE))
    BEGIN
        RAISERROR(N'Thực phẩm đóng hộp phải có hạn sử dụng ít nhất 3 tháng!', 16, 1);
        RETURN;
    END

    DECLARE @NewMaSP VARCHAR(10);

    UPDATE dbo.sequenceCounter SET id = id + 1 WHERE sq_name = 'MaSP';
    SELECT @NewMaSP = 'PRO' + RIGHT('00000' + CAST(id AS VARCHAR(5)), 5)
    FROM dbo.sequenceCounter WHERE sq_name = 'MaSP';

    INSERT INTO SanPham (MaSP, TenSP, GiaTien, MoTa, LoaiSP)
    VALUES (@NewMaSP, @TenSP, @GiaTien, @MoTa, N'Thực phẩm đóng hộp');

    INSERT INTO ThucPhamDongHop (MaSP, ThanhPhan, HanSuDung, NhaSanXuat)
    VALUES (@NewMaSP, @ThanhPhan, @HanSuDung, @NhaSX);

    PRINT N'Thêm thực phẩm đóng hộp thành công! Mã SP: ' + @NewMaSP;
END
GO




CREATE OR ALTER PROCEDURE EditSanPham
    @MaSP       VARCHAR(8),
    @TenSP      NVARCHAR(150),
    @GiaTien    DECIMAL(12,2),
    @MoTa       NVARCHAR(1000) = NULL,
    @LoaiSP     NVARCHAR(30)
AS
BEGIN
    -- 1. Thiết lập NOCOUNT ON để tránh gửi các thông báo không cần thiết về client
    SET NOCOUNT ON;

    -- 2. Kiểm tra xem sản phẩm có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM SanPham WHERE MaSP = @MaSP)
    BEGIN
        -- Báo lỗi nếu sản phẩm không tồn tại
        RAISERROR(N'Lỗi: Không tìm thấy sản phẩm có mã %s để cập nhật.', 16, 1, @MaSP);
        RETURN 0;
    END

    -- 3. Thực hiện lệnh cập nhật (UPDATE)
    UPDATE SanPham
    SET
        TenSP = @TenSP,
        GiaTien = @GiaTien,
        MoTa = @MoTa,
        LoaiSP = @LoaiSP
    WHERE
        MaSP = @MaSP;

    -- 4. Kiểm tra xem có bao nhiêu dòng đã được cập nhật
    IF @@ROWCOUNT > 0
    BEGIN
        RETURN 1;
    END
    ELSE
    BEGIN
        SELECT N'Không có thay đổi nào được thực hiện.' AS ThongBao;
        RETURN 1;
    END

END
GO






CREATE OR ALTER PROCEDURE DeleteSanPham
    @MaSP VARCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    -- 1. Kiểm tra xem sản phẩm có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM SanPham WHERE MaSP = @MaSP)
    BEGIN
        -- Nếu không tồn tại, ROLLBACK
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        RAISERROR(N'Lỗi: Không tìm thấy sản phẩm có mã %s để xóa.', 16, 1, @MaSP);
        RETURN 0;
    END

    -- 2. Thực hiện xóa
    DELETE FROM SanPham
    WHERE MaSP = @MaSP;

    -- 3. Kiểm tra số dòng đã được xóa
    IF @@ROWCOUNT > 0
    BEGIN
        -- Xóa thành công, COMMIT
        COMMIT TRANSACTION;
        RETURN 1;
    END
    ELSE
    BEGIN
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        RAISERROR(N'Lỗi: Xóa sản phẩm có mã %s thất bại.', 16, 1, @MaSP);
        RETURN 0;
    END
END
GO




-- ==========================================
-- TEST DỮ LIỆU
-- ==========================================


-- Thêm sản phẩm tươi sống
EXEC Add_DoTuoiSong N'Cà Chua Đà Lạt', 25000.00, N'Cà chua bi Đà Lạt, dùng làm salad', 5.0, N'VN', '2026-11-25';
EXEC Add_DoTuoiSong N'Gạo Thơm', 120000.00, N'Bao 5kg gạo thơm đặc sản', 5.0, N'VN', '2026-11-25';
EXEC Add_DoTuoiSong N'Khoai Tay Đà Lạt', 42000.00, N'Túi 1kg khoai tây vàng tươi', 5.0, N'VN', '2026-11-25';
EXEC Add_DoTuoiSong N'Táo Đỏ Mỹ', 35000.00, N'Táo Galamus New Zealand, ngon ngọt, giòn tan', 5.0, N'VN', '2026-11-25';
EXEC Add_DoTuoiSong N'Thịt Bò Phi Lê', 199000.00, N'Thịt bò Úc cắt lát dày 1.5cm, tươi mới', 5.0, N'VN', '2026-11-25';
EXEC Add_DoTuoiSong N'Trứng Gà Ta', 38000.00, N'Vỉ 10 quả trứng gà ta, đảm bảo chất lượng', 5.0, N'VN', '2026-11-25';
EXEC Add_DoTuoiSong N'Dưa Leo Baby', 18000.00, N'Dưa leo giống Nhật, giòn ngọt, tươi mát', 4.0, N'VN', '2026-11-30';
EXEC Add_DoTuoiSong N'Cải Bó Xôi', 30000.00, N'Rau bina tươi, giàu sắt và vitamin', 3.0, N'VN', '2026-11-28';
EXEC Add_DoTuoiSong N'Sữa Tươi Nguyên Kem', 48000.00, N'Hộp 1 lít sữa tươi tiệt trùng, béo ngậy', 5.0, N'Úc', '2026-03-15';
EXEC Add_DoTuoiSong N'Cá Hồi Fillet', 350000.00, N'Miếng cá hồi Na Uy tươi, đã lóc xương', 2.0, N'Na Uy', '2026-11-27';
EXEC Add_DoTuoiSong N'Nước Cam Tươi', 55000.00, N'Chai 1 lít nước cam ép 100%, không đường', 5.0, N'VN', '2026-12-05';
EXEC Add_DoTuoiSong N'Chuối Tây', 20000.00, N'Nải chuối Tây chín vàng, cung cấp kali', 5.0, N'VN', '2026-11-29';
EXEC Add_DoTuoiSong N'Thịt Heo Ba Rọi', 115000.00, N'Thịt heo sạch, dùng để kho hoặc chiên', 3.0, N'VN', '2026-11-26';

-- Thêm sản phẩm đồ gia dụng
EXEC Add_DoGiaDung N'Kem Đánh Răng', 28000.00, N'Tuýp 180g kem đánh răng tạo bọt', N'không', N'12 tháng', N'PS';
EXEC Add_DoGiaDung N'Giày Vệ Sinh', 55000.00, N'Gói lớn 10 cuộn giấy 3 lớp', N'Giấy', N'12 tháng', N'GiayTot';
EXEC Add_DoGiaDung N'Nước Lau Sàn', 35000.00, N'Chai 1 lít, hương hoa hạ, sạch khuẩn', N'Chất tẩy rửa', N'24 tháng', N'Sunlight';
EXEC Add_DoGiaDung N'Dầu Gội Đầu', 89000.00, N'Chai 450ml, chiết xuất bồ kết, ngăn rụng tóc', N'Thảo dược', N'36 tháng', N'Clear';
EXEC Add_DoGiaDung N'Bàn Chải Đánh Răng', 25000.00, N'Bộ 2 cái, lông mềm mại, bảo vệ nướu', N'Nhựa', N'12 tháng', N'Colgate';
EXEC Add_DoGiaDung N'Nước Rửa Chén', 42000.00, N'Chai lớn 800g, hương chanh, siêu sạch', N'Chất tẩy rửa', N'24 tháng', N'Mỹ Hảo';
EXEC Add_DoGiaDung N'Khăn Giấy Ướt', 15000.00, N'Gói 100 tờ, không cồn, an toàn cho da em bé', N'Vải không dệt', N'18 tháng', N'Bobby';
EXEC Add_DoGiaDung N'Pin AA', 70000.00, N'Vỉ 4 viên pin tiểu, năng lượng cao', N'Pin kiềm', N'36 tháng', N'Energizer';

-- Thêm thực phẩm đóng hộp
EXEC Add_ThucPhamDongHop N'Cà Phê Đen', 65000.00, N'Gói 500g cà phê rang xay nguyên chất', N'Cà phê', N'Công ty CaPheDen', '2026-11-25';
EXEC Add_ThucPhamDongHop N'Bánh Mì Sandwich', 18000.00, N'Túi 10 lát bánh mì nguyên cám', N'Bột mì', N'Công ty NewBread', '2026-11-25';
EXEC Add_ThucPhamDongHop N'Đường Cát Trắng', 22500.00, N'Túi 1kg đường tinh luyện', N'Đường', N'Công ty DuongMia', '2026-11-25';
EXEC Add_ThucPhamDongHop N'Nước Mắm Nam Ngư', 45000.00, N'Chai 750ml nước mắm cá cơm', N'Cá cơm, muối', N'Công ty Nuoc Mam Ngon', '2026-11-25';
EXEC Add_ThucPhamDongHop N'Muối I-ốt', 9900.00, N'Gói 500g muối i-ốt', N'Muối, Iot', N'Công ty MuoiBien', '2026-11-25';
EXEC Add_ThucPhamDongHop N'Bia Sài Gòn', 15000.00, N'Lon bia 330ml, uống lạnh ngon hơn', N'Nước, Lúa mạch', N'Công ty Bia So 1', '2026-11-25';
EXEC Add_ThucPhamDongHop N'Sữa Tươi Không Đường', 32000.00, N'Hộp 1 lít sữa tươi thanh trùng', N'Sữa', N'Công ty Sua VN', '2026-11-25';
EXEC Add_ThucPhamDongHop N'Mì Tôm Hảo Hảo', 80000.00, N'Thùng 30 gói mì tôm chua cay, nổi tiếng Việt Nam', N'Bột mì, gia vị', N'Acecook', '2026-06-20';
EXEC Add_ThucPhamDongHop N'Cháo Yến Mạch', 95000.00, N'Hộp 500g yến mạch cán dẹt, tốt cho tim mạch', N'Yến mạch', N'Quaker', '2027-01-10';
EXEC Add_ThucPhamDongHop N'Dầu Ăn Cái Lân', 58000.00, N'Chai 2 lít dầu ăn thực vật, chiên xào tiện lợi', N'Dầu cọ', N'Công ty Calan', '2026-09-01';
EXEC Add_ThucPhamDongHop N'Thịt Hộp SPAM', 120000.00, N'Lon 340g thịt nguội đóng hộp, tiện lợi', N'Thịt heo, muối', N'Hormel Foods', '2027-05-20';
EXEC Add_ThucPhamDongHop N'Bánh Quy Bơ', 75000.00, N'Hộp thiếc 400g bánh quy bơ Đan Mạch', N'Bột mì, bơ', N'Kjeldsens', '2026-12-12';
EXEC Add_ThucPhamDongHop N'Trà Xanh Không Đường', 20000.00, N'Chai 500ml trà xanh, giải khát, ít calo', N'Trà xanh', N'Suntory', '2026-04-18';
EXEC Add_ThucPhamDongHop N'Tương Ớt Chin-su', 18000.00, N'Chai 250g tương ớt, vị cay dịu, đậm đà', N'Ớt, tỏi', N'Masancap', '2026-10-05';


-- ==========================================
-- KIỂM TRA KẾT QUẢ SIÊU ĐẸP (DÙNG CHO BẢN BÁO CÁO)
-- ==========================================

SELECT *
FROM SanPham 
ORDER BY MaSP;

SELECT * FROM DoTuoiSong;

SELECT * FROM DoGiaDung;

SELECT * FROM ThucPhamDongHop;
GO






-- ======================================
-- CART RELATED SCRIPTS
-- ======================================


-- ======================================
-- CART RELATED SCRIPTS
-- ======================================


-- ======================================
-- CART RELATED SCRIPTS
-- ======================================


-- Sequence for generating MaGioHang
CREATE SEQUENCE MaGioHang_Seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE  
    CACHE 50;
GO

-- GioHang Table
CREATE TABLE [GioHang] (
    MaGioHang VARCHAR(8) PRIMARY KEY, 
    UserID VARCHAR(8) NOT NULL UNIQUE, 
    TongSoTien DECIMAL(12, 2) DEFAULT 0.00,
    
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO

-- GioHangItem Table
CREATE TABLE [GioHangItem] (
    MaGioHang VARCHAR(8) NOT NULL,
    MaSP VARCHAR(8) NOT NULL,
    SoLuong INT NOT NULL,

    PRIMARY KEY (MaGioHang, MaSP),
    CONSTRAINT CK_GioHangItem_SoLuong CHECK (SoLuong > 0), 
    
    FOREIGN KEY (MaGioHang) REFERENCES [GioHang](MaGioHang),
    FOREIGN KEY (MaSP) REFERENCES [SanPham](MaSP) 
);
GO









-- Insert new GioHang
CREATE PROCEDURE InsertGioHang (
    @p_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_NextValue INT;
    DECLARE @v_NewMaGioHang VARCHAR(8);
    
    -- 1. Get the next value from the sequence
    SET @v_NextValue = NEXT VALUE FOR MaGioHang_Seq;
    
    -- 2. Format new ID (prefix 'CAR' + 5 digits)
    SET @v_NewMaGioHang = 'CAR' + FORMAT(@v_NextValue, 'D5');
    
    -- 3. Insert the new cart record
    INSERT INTO [GioHang] (MaGioHang, UserID)
    VALUES (@v_NewMaGioHang, @p_UserID);
    
    -- Return generated Cart ID
    SELECT @v_NewMaGioHang AS ReturnNewCartID;
END;
GO









-- Function to calculate the total price for a given cart
CREATE FUNCTION ufn_CalculateCartTotal (@p_MaGioHang VARCHAR(8))
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @v_Total DECIMAL(12, 2);

    SELECT 
        @v_Total = SUM(GI.SoLuong * P.GiaTien)
    FROM 
        [GioHangItem] GI
    INNER JOIN 
        [SanPham] P ON GI.MaSP = P.MaSP
    WHERE 
        GI.MaGioHang = @p_MaGioHang;

    RETURN ISNULL(@v_Total, 0.00); 
END;
GO









-- Trigger to update TongSoTien in GioHang after changes to GioHangItem
CREATE TRIGGER trg_UpdateGioHangTotal
ON [GioHangItem]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Determine the MaGioHang values affected by the operation
    DECLARE @AffectedCartIDs TABLE (MaGioHang VARCHAR(8) PRIMARY KEY);
    
    INSERT INTO @AffectedCartIDs (MaGioHang)
    SELECT MaGioHang FROM INSERTED
    UNION
    SELECT MaGioHang FROM DELETED;

    -- Update the TongSoTien for all affected carts using the UDF
    UPDATE GH
    SET TongSoTien = dbo.ufn_CalculateCartTotal(AC.MaGioHang)
    FROM [GioHang] GH
    INNER JOIN @AffectedCartIDs AC ON GH.MaGioHang = AC.MaGioHang;
END;
GO












-- Creating 6 Carts
EXEC InsertGioHang 'USE00001';
EXEC InsertGioHang 'USE00002';
EXEC InsertGioHang 'USE00003';
EXEC InsertGioHang 'USE00004';
EXEC InsertGioHang 'USE00005';
EXEC InsertGioHang 'USE00006';
GO

-- Cart 1 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00001', 'PRO00001', 5),
('CAR00001', 'PRO00003', 1), 
('CAR00001', 'PRO00005', 3), 
('CAR00001', 'PRO00012', 1); 
GO

-- Cart 2 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00002', 'PRO00002', 1), 
('CAR00002', 'PRO00004', 2), 
('CAR00002', 'PRO00008', 1),
('CAR00002', 'PRO00007', 1);
GO

-- Cart 3 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00003', 'PRO00006', 2),
('CAR00003', 'PRO00009', 1),
('CAR00003', 'PRO00010', 1),
('CAR00003', 'PRO00013', 6);
GO

-- Cart 4 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00004', 'PRO00001', 1),
('CAR00004', 'PRO00004', 1),
('CAR00004', 'PRO00011', 1),
('CAR00004', 'PRO00014', 2);
GO

-- Cart 5 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00005', 'PRO00015', 1), 
('CAR00005', 'PRO00014', 1),
('CAR00005', 'PRO00010', 1),
('CAR00005', 'PRO00008', 1); 
GO

-- Cart 6 (1 item)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00006', 'PRO00003', 1);
GO

-- Display results
SELECT * FROM [GioHang];
SELECT * FROM [GioHangItem];
GO




-- ======================================
-- ORDER RELATED SCRIPTS
-- ======================================


-- ======================================
-- ORDER RELATED SCRIPTS
-- ======================================


-- ======================================
-- ORDER RELATED SCRIPTS
-- ======================================


-- Sequence object for generating MaDon
CREATE SEQUENCE MaDonHang_Seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE  
    CACHE 50;
GO

-- DonHang Table
CREATE TABLE [DonHang] (
    MaDon VARCHAR(8) PRIMARY KEY,
    UserID VARCHAR(8) NOT NULL,
    DiaChi NVARCHAR(255) NOT NULL,
    TrangThai NVARCHAR(20) DEFAULT N'Pending',
    SoTien DECIMAL(12 , 2 ) DEFAULT 0.00,
    NgayDatHang DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (UserID) REFERENCES [User] (UserID),
    
    CONSTRAINT CK_DonHang_TrangThai CHECK (TrangThai IN (
        N'Pending', 
        N'Processing',
        N'Shipping',
        N'Delivered',
        N'Cancelled'
    ))
);
GO

-- DonHangItem Table
CREATE TABLE [DonHangItem] (
    MaDon VARCHAR(8) NOT NULL,
    MaSP VARCHAR(8) NOT NULL,
    SoLuong INT NOT NULL,
    GiaLucBan DECIMAL(10, 2) NOT NULL, -- Price at time of order

    PRIMARY KEY (MaDon, MaSP),
    CONSTRAINT CK_DonHangItem_SoLuong CHECK (SoLuong > 0), 
    CONSTRAINT CK_DonHangItem_GiaLucBan CHECK (GiaLucBan >= 0),
    
    FOREIGN KEY (MaDon) REFERENCES [DonHang](MaDon),
    FOREIGN KEY (MaSP) REFERENCES [SanPham](MaSP)
);
GO








-- Stored Procedure to insert a new order (DonHang)
CREATE PROCEDURE InsertDonHang (
    @p_UserID VARCHAR(8),
    @p_DiaChi NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_NextValue INT;
    DECLARE @v_NewMaDon VARCHAR(8);
    
    -- 1. Get the next value from the sequence
    SET @v_NextValue = NEXT VALUE FOR MaDonHang_Seq;
    
    -- 2. Format new ID (prefix 'ORD' + 5 digits)
    SET @v_NewMaDon = 'ORD' + FORMAT(@v_NextValue, 'D5');
    
    -- 3. Insert the new order record (TrangThai and SoTien default automatically)
    INSERT INTO [DonHang] (MaDon, UserID, DiaChi)
    VALUES (@v_NewMaDon, @p_UserID, @p_DiaChi);

    -- Return the newly generated Order ID
    SELECT @v_NewMaDon AS NewOrderID;
END;
GO







-- Function to calculate the total price for a given order (MaDon)
CREATE FUNCTION ufn_CalculateOrderTotal (@p_MaDon VARCHAR(8))
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @v_Total DECIMAL(12, 2);

    SELECT 
        @v_Total = SUM(DI.SoLuong * DI.GiaLucBan)
    FROM 
        [DonHangItem] DI
    WHERE 
        DI.MaDon = @p_MaDon;

    RETURN ISNULL(@v_Total, 0.00);
END;
GO








-- Insert one item into one DonHang
CREATE PROCEDURE InsertDonHangItem (
    @p_MaDon VARCHAR(8), 
    @p_MaSP VARCHAR(8), 
    @p_SoLuong INT 
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_GiaLucBan DECIMAL(10, 2); 
    
    -- 1. Get GiaTien from SanPham
    SELECT @v_GiaLucBan = GiaTien
    FROM SanPham
    WHERE MaSP = @p_MaSP;

    -- Check if price was found
    IF @v_GiaLucBan IS NULL 
    BEGIN
        -- Raise an error if product doesn't exist
        ;THROW 51000, 'Error: Product ID (MaSP) not found in SanPham table.', 1;
        RETURN;
    END
    
    -- Check if SoLuong is valid before insert
    IF @p_SoLuong <= 0
    BEGIN
        ;THROW 51001, 'Error: SoLuong must be greater than zero.', 1;
        RETURN;
    END

    -- 2. Insert the new order item
    INSERT INTO [DonHangItem] (MaDon, MaSP, SoLuong, GiaLucBan)
    VALUES (@p_MaDon, @p_MaSP, @p_SoLuong, @v_GiaLucBan);
END;
GO












-- Trigger to enforce valid status change on DonHang
CREATE TRIGGER trg_EnforceTrangThaiOrder
ON [DonHang]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if was actually changed
    IF UPDATE(TrangThai)
    BEGIN
        -- Find any rows where the old status (DELETED) and new status (INSERTED) 
        -- represent an invalid change according to the business rules.
        IF EXISTS (
            SELECT 1
            FROM DELETED d
            INNER JOIN INSERTED i ON d.MaDon = i.MaDon
            WHERE 
                (d.TrangThai = N'Pending' AND i.TrangThai NOT IN (N'Processing', N'Cancelled')) OR
                (d.TrangThai = N'Processing' AND i.TrangThai NOT IN (N'Shipping', N'Cancelled')) OR
                (d.TrangThai = N'Shipping' AND i.TrangThai <> N'Delivered') OR
                -- No changes for Delivered or Cancelled
                (d.TrangThai IN (N'Delivered', N'Cancelled'))
        )
        BEGIN
            -- Throw an error for the transaction and rollback
            ;THROW 50001, 'Invalid order status transition. Status must follow: Pending -> Processing -> Shipping -> Delivered, or Cancelled.', 1;
            RETURN;
        END
    END
END;
GO









CREATE PROCEDURE UpdateOrderStatus
    @MaDon VARCHAR(8),
    @NewTrangThai NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Check if order exists
        IF NOT EXISTS (SELECT 1 FROM [DonHang] WHERE MaDon = @MaDon)
        BEGIN
            ;THROW 50002, 'Order ID (MaDon) not found.', 1;
            RETURN;
        END

        -- Attempt update. 
        UPDATE [DonHang]
        SET TrangThai = @NewTrangThai
        WHERE MaDon = @MaDon;

        -- If the update succeeds, confirm change.
        IF @@ROWCOUNT > 0
        BEGIN
            SELECT 
                'SUCCESS' AS Result, 
                @MaDon AS MaDon, 
                @NewTrangThai AS NewTrangThai,
                N'Order status updated successfully.' AS Message;
        END
        ELSE
        BEGIN
             -- fallback
             SELECT 
                'INFO' AS Result, 
                @MaDon AS MaDon, 
                @NewTrangThai AS NewTrangThai,
                N'Order status was already set to this value, no change made.' AS Message;
        END

    END TRY
    BEGIN CATCH
        -- If an error was thrown, capture and return it.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW; 
    END CATCH
END
GO








-- Trigger to update SoTien in DonHang after changes to DonHangItem
CREATE TRIGGER trg_UpdateDonHangTotal
ON [DonHangItem]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Determine the MaDon values affected by the operation
    DECLARE @AffectedOrderIDs TABLE (MaDon VARCHAR(8) PRIMARY KEY);
    
    INSERT INTO @AffectedOrderIDs (MaDon)
    SELECT MaDon FROM INSERTED
    UNION
    SELECT MaDon FROM DELETED;

    -- Update the SoTien for all affected orders using the UDF
    UPDATE DH
    SET SoTien = dbo.ufn_CalculateOrderTotal(AO.MaDon)
    FROM [DonHang] DH
    INNER JOIN @AffectedOrderIDs AO ON DH.MaDon = AO.MaDon;
END;
GO















-- 6 Inital Orders
EXEC InsertDonHang 'USE00001', N'123 Phan Van Tri, Q. Go Vap';
EXEC InsertDonHang 'USE00002', N'45 Tran Hung Dao, Q. 1';
EXEC InsertDonHang 'USE00003', N'789 Le Loi, Q. Binh Thanh';
EXEC InsertDonHang 'USE00004', N'50 Dien Bien Phu, Q. 3';
EXEC InsertDonHang 'USE00005', N'30 Vo Thi Sau, Q. Tan Binh';
EXEC InsertDonHang 'USE00006', N'10 Nguyen Hue, Q. 1';
GO

-- Order 1 (5 items)
EXEC InsertDonHangItem 'ORD00001', 'PRO00001', 3;
EXEC InsertDonHangItem 'ORD00001', 'PRO00004', 1;
EXEC InsertDonHangItem 'ORD00001', 'PRO00006', 2;
EXEC InsertDonHangItem 'ORD00001', 'PRO00009', 1;
EXEC InsertDonHangItem 'ORD00001', 'PRO00011', 1;
GO

-- Order 2 (5 items)
EXEC InsertDonHangItem 'ORD00002', 'PRO00002', 2;
EXEC InsertDonHangItem 'ORD00002', 'PRO00005', 1;
EXEC InsertDonHangItem 'ORD00002', 'PRO00013', 1;
EXEC InsertDonHangItem 'ORD00002', 'PRO00008', 1;
EXEC InsertDonHangItem 'ORD00002', 'PRO00014', 1;
GO

-- Order 3 (5 items)
EXEC InsertDonHangItem 'ORD00003', 'PRO00001', 10;
EXEC InsertDonHangItem 'ORD00003', 'PRO00002', 3;
EXEC InsertDonHangItem 'ORD00003', 'PRO00003', 5;
EXEC InsertDonHangItem 'ORD00003', 'PRO00007', 1;
EXEC InsertDonHangItem 'ORD00003', 'PRO00015', 1;
GO

-- Order 4 (5 items)
EXEC InsertDonHangItem 'ORD00004', 'PRO00003', 1;
EXEC InsertDonHangItem 'ORD00004', 'PRO00007', 2;
EXEC InsertDonHangItem 'ORD00004', 'PRO00012', 1;
EXEC InsertDonHangItem 'ORD00004', 'PRO00010', 1;
EXEC InsertDonHangItem 'ORD00004', 'PRO00011', 1;
GO

-- Order 5 (5 items)
EXEC InsertDonHangItem 'ORD00005', 'PRO00004', 3;
EXEC InsertDonHangItem 'ORD00005', 'PRO00006', 1;
EXEC InsertDonHangItem 'ORD00005', 'PRO00009', 2;
EXEC InsertDonHangItem 'ORD00005', 'PRO00013', 1;
EXEC InsertDonHangItem 'ORD00005', 'PRO00015', 1;
GO

-- Order 6 (1 item)
EXEC InsertDonHangItem 'ORD00006', 'PRO00003', 1; 
GO



-- Order 7 (User USE00007)
EXEC InsertDonHang 'USE00007', N'22/3 Cong Hoa, Q. Tan Binh';
GO

-- Order 8 (User USE00008)
EXEC InsertDonHang 'USE00008', N'120 Pasteur, Q. 1';
GO

-- Order 9 (User USE00009)
EXEC InsertDonHang 'USE00009', N'345 Truong Chinh, Q. Tan Phu';
GO

-- Order 10 (User USE00010)
EXEC InsertDonHang 'USE00010', N'88 Cach Mang Thang Tam, Q. 3';
GO

-- Order 11 (User USE00001 - Reordering)
EXEC InsertDonHang 'USE00001', N'123 Phan Van Tri, Q. Go Vap';
GO

-- Order 12 (User USE00005 - Reordering)
EXEC InsertDonHang 'USE00005', N'30 Vo Thi Sau, Q. Tan Binh';
GO

--- Add Items to New Orders ---

-- Order 7 (5 items)
EXEC InsertDonHangItem 'ORD00007', 'PRO00001', 1;
EXEC InsertDonHangItem 'ORD00007', 'PRO00002', 1;
EXEC InsertDonHangItem 'ORD00007', 'PRO00003', 1;
EXEC InsertDonHangItem 'ORD00007', 'PRO00004', 1;
EXEC InsertDonHangItem 'ORD00007', 'PRO00005', 1;
GO

-- Order 8 (4 items)
EXEC InsertDonHangItem 'ORD00008', 'PRO00006', 2;
EXEC InsertDonHangItem 'ORD00008', 'PRO00007', 3;
EXEC InsertDonHangItem 'ORD00008', 'PRO00008', 1;
EXEC InsertDonHangItem 'ORD00008', 'PRO00009', 4;
GO

-- Order 9 (2 items)
EXEC InsertDonHangItem 'ORD00009', 'PRO00010', 5;
EXEC InsertDonHangItem 'ORD00009', 'PRO00011', 2;
GO

-- Order 10 (3 items)
EXEC InsertDonHangItem 'ORD00010', 'PRO00012', 1;
EXEC InsertDonHangItem 'ORD00010', 'PRO00013', 2;
EXEC InsertDonHangItem 'ORD00010', 'PRO00014', 1;
GO

-- Order 11 (User USE00001 - 5 items)
EXEC InsertDonHangItem 'ORD00011', 'PRO00005', 2;
EXEC InsertDonHangItem 'ORD00011', 'PRO00006', 1;
EXEC InsertDonHangItem 'ORD00011', 'PRO00010', 1;
EXEC InsertDonHangItem 'ORD00011', 'PRO00011', 3;
EXEC InsertDonHangItem 'ORD00011', 'PRO00015', 1;
GO

-- Order 12 (User USE00005 - 1 item)
EXEC InsertDonHangItem 'ORD00012', 'PRO00002', 5;
GO





SELECT * FROM [DonHang];
SELECT * FROM [DonHangItem];
GO







-- ======================================
-- DIACHI RELATED SCRIPTS
-- ======================================


-- ======================================
-- DIACHI RELATED SCRIPTS
-- ======================================


-- ======================================
-- DIACHI RELATED SCRIPTS
-- ======================================


CREATE TABLE [DiaChi] (
    UserID VARCHAR(8) PRIMARY KEY, 
    TinhThanh NVARCHAR(50),
    PhuongXa NVARCHAR(50),
    DuongVaSoNha NVARCHAR(200),
    
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO







-- Retrieve address by UserID
CREATE PROCEDURE GetDiaChiByUserID (
    @input_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        UserID,
        TinhThanh,
        PhuongXa,
        DuongVaSoNha
    FROM
        [DiaChi]
    WHERE
        UserID = @input_UserID;
END
GO








-- Inserting sample address data for UserIDs USE00001 to USE00010

INSERT INTO [DiaChi] (UserID, TinhThanh, PhuongXa, DuongVaSoNha) VALUES
('USE00001', N'Thành phố Hà Nội', N'Phường ABC', N'Số 10, ngõ 175, Giải Phóng'),
('USE00002', N'Thành phố Hồ Chí Minh', N'Phường 12', N'123 Đường Nguyễn Huệ, Quận 1'),
('USE00003', N'Thành phố Đà Nẵng', N'Phường Hải Châu I', N'45 Đường Bạch Đằng'),
('USE00004', N'Tỉnh Thừa Thiên Huế', N'Phường Vĩnh Ninh', N'200 Đường Hùng Vương'),
('USE00005', N'Thành phố Hải Phòng', N'Phường Máy Tơ', N'Lô 5, Khu đô thị Vinhomes'),
('USE00006', N'Tỉnh Cần Thơ', N'Phường Cái Khế', N'Số 88, Đường 30 Tháng 4'),
('USE00007', N'Tỉnh Quảng Ninh', N'Phường Bãi Cháy', N'1A Đường Hạ Long'),
('USE00008', N'Tỉnh Khánh Hòa', N'Phường Lộc Thọ', N'79 Đường Trần Phú, Nha Trang'),
('USE00009', N'Tỉnh Đồng Nai', N'Phường Trảng Dài', N'Khu phố 4, Đường Nguyễn Ái Quốc'),
('USE00010', N'Tỉnh Bình Dương', N'Phường Thuận Giao', N'Số 33, Đại lộ Bình Dương');
GO

-- Display results
SELECT * FROM [DiaChi];
GO







-- ======================================
-- THANHTOAN RELATED SCRIPTS
-- ======================================


-- ======================================
-- THANHTOAN RELATED SCRIPTS
-- ======================================


-- ======================================
-- THANHTOAN RELATED SCRIPTS
-- ======================================



CREATE TABLE [ThanhToan] (
    MaThanhToan INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    UserID VARCHAR(8),
    MaDon VARCHAR(8),
    SoTien DECIMAL(12,2),
    NgayGio DATETIME DEFAULT GETDATE(),
    PhuongThuc NVARCHAR(40),
    GhiChu NVARCHAR(200),
    
    CONSTRAINT CK_ThanhToan_SoTien CHECK (SoTien > 0),
    
    FOREIGN KEY (UserID) REFERENCES [User](UserID),
    FOREIGN KEY (MaDon) REFERENCES [DonHang](MaDon)
);
GO








-- Stored Procedure to insert a new payment record
CREATE PROCEDURE InsertThanhToan (
    @input_MaDon VARCHAR(8),
    @input_PhuongThuc NVARCHAR(40),
    @input_GhiChu NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @v_UserID VARCHAR(8);
    DECLARE @v_SoTien DECIMAL(12,2);
    
    -- 1. Fetch UserID and SoTien from the DonHang table
    SELECT
        @v_UserID = UserID, 
        @v_SoTien = SoTien
    FROM
        [DonHang] DH
    WHERE
        DH.MaDon = @input_MaDon;

    -- Check if the order was found and has a positive amount
    IF @v_UserID IS NULL
    BEGIN
        ;THROW 51000, 'Error: Order ID (MaDon) not found.', 1;
        RETURN;
    END

    -- 2. Insert new payment record
    INSERT INTO [ThanhToan] (UserID, MaDon, SoTien, PhuongThuc, GhiChu) 
    VALUES (@v_UserID, @input_MaDon, @v_SoTien, @input_PhuongThuc, @input_GhiChu);
END
GO







-- Retrieve ThanhToan by MaDon
CREATE PROCEDURE GetThanhToanByMaDon (
    @input_MaDon VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        MaThanhToan,
        UserID,
        MaDon,
        SoTien,
        NgayGio,
        PhuongThuc,
        GhiChu
    FROM
        [ThanhToan]
    WHERE
        MaDon = @input_MaDon;
END
GO










-- Insert sample payment
EXEC InsertThanhToan @input_MaDon = 'ORD00001', 
    @input_PhuongThuc = N'Cash', 
    @input_GhiChu = N'Hello this ghi chu hello';
GO

-- Display results
SELECT * FROM [ThanhToan];
GO







-- ======================================
-- FUNCTIONS RELATED SCRIPTS
-- ======================================


-- ======================================
-- FUNCTIONS RELATED SCRIPTS
-- ======================================


-- ======================================
-- FUNCTIONS RELATED SCRIPTS
-- ======================================


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