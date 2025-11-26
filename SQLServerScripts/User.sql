CREATE TABLE [User] (
    UserID VARCHAR(8) PRIMARY KEY, 
    Password NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10) NOT NULL, 
    SoDienThoai VARCHAR(20) UNIQUE, 
    Email VARCHAR(100) NOT NULL UNIQUE,
    
    -- Constraint to enforce 'Nam' or 'Nu' for GioiTinh
    CONSTRAINT CK_User_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nu'))
);

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