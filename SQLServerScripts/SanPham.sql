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

CREATE TABLE DoGiaDung (
    MaSP VARCHAR(8) PRIMARY KEY,
    ChatLieu VARCHAR(100),
    BaoHanh VARCHAR(50) DEFAULT '12 tháng',
    ThuongHieu VARCHAR(100),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

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
EXEC Add_DoTuoiSong N'Cà Chua Đà Lạt', 25000.00, N'Cà chua bi Đà Lạt, dùng làm salad', 5.0, N'VN', '2025-11-25';
EXEC Add_DoTuoiSong N'Gạo Thơm', 120000.00, N'Bao 5kg gạo thơm đặc sản', 5.0, N'VN', '2025-11-25';
EXEC Add_DoTuoiSong N'Khoai Tay Đà Lạt', 42000.00, N'Túi 1kg khoai tây vàng tươi', 5.0, N'VN', '2025-11-25';
EXEC Add_DoTuoiSong N'Táo Đỏ Mỹ', 35000.00, N'Táo Galamus New Zealand, ngon ngọt, giòn tan', 5.0, N'VN', '2025-11-25';
EXEC Add_DoTuoiSong N'Thịt Bò Phi Lê', 199000.00, N'Thịt bò Úc cắt lát dày 1.5cm, tươi mới', 5.0, N'VN', '2025-11-25';
EXEC Add_DoTuoiSong N'Trứng Gà Ta', 38000.00, N'Vỉ 10 quả trứng gà ta, đảm bảo chất lượng', 5.0, N'VN', '2025-11-25';
EXEC Add_DoTuoiSong N'Dưa Leo Baby', 18000.00, N'Dưa leo giống Nhật, giòn ngọt, tươi mát', 4.0, N'VN', '2025-11-30';
EXEC Add_DoTuoiSong N'Cải Bó Xôi', 30000.00, N'Rau bina tươi, giàu sắt và vitamin', 3.0, N'VN', '2025-11-28';
EXEC Add_DoTuoiSong N'Sữa Tươi Nguyên Kem', 48000.00, N'Hộp 1 lít sữa tươi tiệt trùng, béo ngậy', 5.0, N'Úc', '2026-03-15';
EXEC Add_DoTuoiSong N'Cá Hồi Fillet', 350000.00, N'Miếng cá hồi Na Uy tươi, đã lóc xương', 2.0, N'Na Uy', '2025-11-27';
EXEC Add_DoTuoiSong N'Nước Cam Tươi', 55000.00, N'Chai 1 lít nước cam ép 100%, không đường', 5.0, N'VN', '2025-12-05';
EXEC Add_DoTuoiSong N'Chuối Tây', 20000.00, N'Nải chuối Tây chín vàng, cung cấp kali', 5.0, N'VN', '2025-11-29';
EXEC Add_DoTuoiSong N'Thịt Heo Ba Rọi', 115000.00, N'Thịt heo sạch, dùng để kho hoặc chiên', 3.0, N'VN', '2025-11-26';

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