EXEC GetTopPurchasedItems 'USE00001', 5;
EXEC GetMaGioHangByUserID 'USE00001' ;
EXEC GetCartContentByMaGioHang 'CAR00001';
EXEC GetCartContentByUserID 'USE00001';
EXEC GetOrderListByUserID 'USE00001';
EXEC GetOrderContentByMaDon 'ORD00001';


EXEC GetDiaChiByUserID 'USE00001';
EXEC GetThanhToanByMaDon 'ORD00001';

EXEC GetUsersPaged 2, 10;
EXEC GetProductsPaged 1, 10;
EXEC GetOrdersPaged 1, 3;
EXEC GetOrderListByUserIDPaged 'USE00001',1, 3;

EXEC GetSanPhamByCategory N'Khác',1,20;
EXEC GetSanPhamSortedByGiaTien 'DESC',1,20;
EXEC SearchSanPham N'Bình đuasdfasdfn',1,20;