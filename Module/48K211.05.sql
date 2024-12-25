---Module tạo dữ liệu
USE QLBanhang;
go
-- 1. Nhap du lieu cho bang SanPham
create or alter procedure NhapDuLieuSanPham @SoLuongSanPham int
as
begin
    declare @i int = 1
    while @i <= @SoLuongSanPham
    begin
        insert into SanPham (MaSP, TenSP, SoLuong, DVT) 
		values ('SP' + RIGHT('00000000' + cast(@i as varchar(8)), 8), 
				N'Sản phẩm ' + cast(@i as nvarchar(10)),floor(rand() * 100 + 1),  N'Cái')
        set @i = @i + 1
    end
end
go
exec NhapDuLieuSanPham 1000
select * from SanPham 
 
 -- 2. Nhap du lieu cho bang KhachHang
go
create or alter procedure NhapDuLieuKhachHang @SoLuongKhachHang int
as
begin
    declare @i int = 1, @SDT char(10), @PhonePrefix char(3)
	declare @PhonePrefixes TABLE (Prefix CHAR(3))
    insert into @PhonePrefixes (Prefix)
    values
        ('096'), ('097'), ('098'), ('086'),  
        ('088'), ('091'), ('094'), ('081'), ('082'), ('083'), ('084'), ('085'),  
        ('090'), ('093'), ('089'), ('070'), ('079'), ('077'), ('078');
    while @i <= @SoLuongKhachHang
		begin
			select top 1 @PhonePrefix = Prefix from @PhonePrefixes order by newid()
			set @SDT = @PhonePrefix + format(floor(rand() * 10000000), '0000000')
			if not exists (select 1 from KhachHang where SDTKH = @SDT)
			begin
			insert into KhachHang (MaKH, TenKH, SDTKH, DiaChiKH)
			values ('KH' + RIGHT('00000000' + cast(@i as varchar(8)), 8),  
					N'Khách hàng ' + cast(@i as nvarchar(10)), @SDT,  
					N'Địa chỉ khách hàng ' + cast(@i as nvarchar(10)))
			end
        set @i = @i + 1
    end
end
go

exec NhapDuLieuKhachHang 1000
select * from KhachHang

-- 3. Nhap du lieu cho bang NhaCungCap
go
create or alter procedure NhapDuLieuNhaCungCap
    @SoLuongNhaCungCap int
as
begin
    declare @i int = 1
    declare @SDTNCC varchar(10),@PhonePrefix char(3)
	declare @PhonePrefixes TABLE (Prefix CHAR(3))
    insert into @PhonePrefixes (Prefix)
    values('096'), ('097'), ('098'), ('086'),  
        ('088'), ('091'), ('094'), ('081'), ('082'), ('083'), ('084'), ('085'),  
        ('090'), ('093'), ('089'), ('070'), ('079'), ('077'), ('078');

    while @i <= @SoLuongNhaCungCap
    begin
        select top 1 @PhonePrefix = Prefix from @PhonePrefixes order by newid()
        set @SDTNCC = @PhonePrefix + right('0000000' + cast(cast(rand() * 10000000 as int) as varchar(7)), 7)

        insert into NhaCungCap (MaNCC, TenNCC, SDTNCC, DiaChiNCC) values
				('NCC' + RIGHT('0000000' + cast(@i as varchar(7)), 7),
				N'Nhà cung cấp ' + cast(@i as nvarchar(10)), @SDTNCC,  
				N'Địa chỉ nhà cung cấp ' + cast(@i as nvarchar(10)))
        set @i = @i + 1
    end
end
go

exec NhapDuLieuNhaCungCap 1000
select * from NhaCungCap

-- 4. Nhap du lieu cho bang PhieuNhap
--drop PROCEDURE NhapDuLieuPhieuNhap
go
create or alter procedure NhapDuLieuPhieuNhap
    @SoLuongPhieuNhap int
as
begin
    declare @i int = 1, @MaPN char(10), @TongTienPN NUMERIC(20, 0), @MintongTien int = 100000, @MaxTongTien int = 1000000
    while @i <= @SoLuongPhieuNhap
    begin
        set @MaPN = 'PN' + right('00000000' + cast(@i as varchar(8)), 8)
        set @TongTienPN = @MintongTien + cast(rand() * (@MaxTongTien - @MintongTien) as numeric(20, 0))

        insert into PhieuNhap (MaPN, NgayNhap, TongTien, MaNCC) values 
            (@MaPN, GETDATE(), @TongTienPN, (select top 1 MaNCC from NhaCungCap order by newid()))
        set @i = @i + 1
    end
end
go

exec NhapDuLieuPhieuNhap 1000

select * from PhieuNhap


-- 5. Nhap du lieu cho bang PhieuNhapChiTiet
go
create or alter procedure NhapDuLieuPhieuNhapChiTiet @SoLuongPhieuNhapChiTiet int
as
begin
    declare @i int = 1, @DonGiaNhap numeric(10, 2), @SoLuongNhap int, @MaPNCT char(10), @j int = 1
    while @i <= @SoLuongPhieuNhapChiTiet
    begin
        set @SoLuongNhap = floor(rand() * 100 + 1)
        set @DonGiaNhap = floor(rand() * 1000 + 100)
        set @MaPNCT = 'PNCT' + right('000000' + cast(@j as varchar(6)), 6) 

        insert into PhieuNhapChiTiet (MaPNCT, SoLuongNhap, DonGiaNhap, MasP, MaPN) 
		values (@MaPNCT, @SoLuongNhap, @DonGiaNhap, 
				(select top 1 MasP from SanPham order by newid()), 
				(select top 1 MaPN from PhieuNhap order by newid()))

        set @i = @i + 1
		set @j = @j + 1
    end
end
go

exec NhapDuLieuPhieuNhapChiTiet 1000
select * from PhieuNhapChiTiet

-- 6. Nhap du lieu cho bang GiasanPham

go
create or alter procedure NhapDuLieuGiasanPham @SoLuongGiasanPham int
as
begin
    declare @i int = 1, @Gia numeric(10, 0), @MaGiasanPham char(10)
    while @i <= @SoLuongGiasanPham
    begin
        select top 1 @Gia = DonGiaNhap * 1.4 from PhieuNhapChiTiet order by newid();
        set @MaGiasanPham = 'GSP' + right('0000000' + cast((select count(*) from GiasanPham) + @i + 1 as varchar(7)), 7)
        if not exists (select 1 from GiasanPham where MaGiasanPham = @MaGiasanPham)
        begin
            insert into GiasanPham (MaGiasanPham, Gia, NgayApDung, NgayKetThuc, MasP, MaPNCT) 
			values ( @MaGiasanPham, @Gia, GETDATE(), DATEADD(YEAR, 1, GETDATE()), 
                (select top 1 MasP from SanPham order by newid()),  
                (select top 1 MaPNCT from PhieuNhapChiTiet order by newid()))
        end
        else
        begin
            print N'Trùng MaGiasanPham: ' + @MaGiasanPham;
        end
        set @i = @i + 1
    end
end
go

go
exec NhapDuLieuGiasanPham 1000
select * from GiasanPham

-- 7. Nhap du lieu cho bang DonViGiaoHang
go
create or alter procedure NhapDuLieuDonViGiaoHang @SoLuongDonViGiaoHang int
as
begin
    declare @i int = 1, @SDTDV varchar(10), @PhonePrefix char(3)
	declare @PhonePrefixes TABLE (Prefix CHAR(3));
    insert into @PhonePrefixes (Prefix)
    values
        ('096'), ('097'), ('098'), ('086'),  
        ('088'), ('091'), ('094'), ('081'), ('082'), ('083'), ('084'), ('085'),  
        ('090'), ('093'), ('089'), ('070'), ('079'), ('077'), ('078');
    while @i <= @SoLuongDonViGiaoHang
    begin
     
        select top 1 @PhonePrefix = Prefix from @PhonePrefixes order by newid()
        set @SDTDV = @PhonePrefix + right('0000000' + cast(cast(rand() * 10000000 as int) as varchar(7)), 7)
        if not exists (select 1 from DonViGiaoHang where SDTDV = @SDTDV)
        begin
            insert into DonViGiaoHang (MaDV, TendV, SDTDV, DiaChiDV) 
			values( 'DV' + RIGHT('00000000' + cast(@i as varchar(8)), 8), 
					N'Đơn vị giao hàng ' + cast(@i as nvarchar(10)),@SDTDV,                                                
					N'Địa chỉ đơn vị giao hàng ' + cast(@i as nvarchar(10)))
            set @i = @i + 1
        end
    end
end
go

exec NhapDuLieuDonViGiaoHang 1000
select * from DonViGiaoHang

-- 8. Nhap du lieu cho bang DonBanHang
go
create or alter proc NhapDuLieuDonBanHang @SoLuongDonBanHang INT
as
begin
    declare @i INT = 1, 
            @MaDH CHAR(10), 
            @TongTien NUMERIC(20, 0), 
            @LoaiDH BIT, 
            @KhoangCach NUMERIC(5, 2), 
            @NgayShip DATE, 
            @PhiShip NUMERIC(10, 2),
            @MaDV CHAR(10),
            @MaKH CHAR(10)

    while @i <= @SoLuongDonBanHang
    begin
        -- Tạo mã đơn hàng
        set @MaDH = 'DH' + RIGHT('00000000' + CAST(@i AS VARCHAR(8)), 8)
        
        -- Kiểm tra xem mã đơn hàng có tồn tại hay không
        while EXISTS (SELECT 1 FROM DonBanHang WHERE MaDH = @MaDH)
        begin
            set @i = @i + 1
            set @MaDH = 'DH' + RIGHT('00000000' + CAST(@i AS VARCHAR(8)), 8)
        end
        
        -- Tạo tổng tiền ngẫu nhiên
        set @TongTien = ABS(CHECKSUM(NEWID())) % 9000000 + 1000000
        
        -- Xác định loại đơn hàng (0: offline, 1: online)
        set @LoaiDH = CAST(FLOOR(RAND() * 2) AS BIT)
        
        -- Xác định mã khách hàng ngẫu nhiên
        set @MaKH = (SELECT TOP 1 MaKH FROM KhachHang order by NEWID())

        -- Xử lý các đơn hàng online
        if @LoaiDH = 1
        begin
            -- Tạo khoảng cách ngẫu nhiên (1 đến 30 km)
            set @KhoangCach = CAST(FLOOR(RAND() * 30 + 1) AS NUMERIC(5, 2))

            -- Tạo ngày giao hàng (ngày hiện tại + 1 đến 7 ngày)
            set @NgayShip = DATEADD(DAY, FLOOR(RAND() * 7 + 1), GETDATE())

            -- Chọn đơn vị vận chuyển ngẫu nhiên
            set @MaDV = (SELECT TOP 1 MaDV FROM DonViGiaoHang order by NEWID())

            -- Tính phí ship
            if @KhoangCach < 5
            begin
                set @PhiShip = 0
            end
            else
            begin
                set @PhiShip = 30000
            end
        end
        else
        begin
            -- Nếu là đơn offline, không có phí ship và các thông tin giao hàng khác
            set @KhoangCach = NULL
            set @NgayShip = NULL
            set @PhiShip = 0
            set @MaDV = NULL
        end

        -- Thêm dữ liệu vào bảng DonBanHang
        insert into DonBanHang (MaDH, NgayLap, LoaiDH, KhoangCach, NgayShip, PhiShip, TrangThaiDonHang,TongTien, MaKH, MaDV)
        values (@MaDH, GETDATE(), @LoaiDH, @KhoangCach, @NgayShip, @PhiShip, N'Đã giao',@TongTien, @MaKH, @MaDV)

        -- Tăng chỉ số vòng lặp
        set @i = @i + 1
    end
end
GO


exec NhapDuLieuDonBanHang 1000
select * from DonBanHang

-- 8. Nhap du lieu cho bang DonBanHangChiTiet
go
create or alter procedure NhapDuLieuDonBanHangChiTiet
    @SoLuongDonBanHangChiTiet int
as
begin
    declare @i int = 1, @SoLuong int, @DonGia numeric(10, 2), @MasP char(10), @MaDH char(10)
    while @i <= @SoLuongDonBanHangChiTiet
    begin
        select top 1 @MasP = SanPham.MasP,  @DonGia = GiasanPham.Gia
        from SanPham  join GiasanPham  ON SanPham.MasP = GiasanPham.MasP
        where GETDATE() between GiasanPham.NgayApDung AND GiasanPham.NgayKetThuc  
        order by newid()

        select top 1 @MaDH = MaDH 
		from DonBanHang 
		order by newid()
        set @SoLuong = floor(rand() * 10 + 1)

        insert into DonBanHangChiTiet (MaDHCT, SoLuong, DonGia, DVT, MasP, MaDH) values 
				('DHCT' + RIGHT('000000000' + cast(@i as varchar(6)), 6), 
				@SoLuong, @DonGia, N'Cái', @MasP, @MaDH)
        set @i = @i + 1
    end
end
go

go
exec NhapDuLieuDonBanHangChiTiet 1000
select * from DonBanHangChiTiet

---CÁC MODULE 
--cau1 Trigger cập nhật giá sản phẩm khi nhập hàng mới
create or alter trigger trg_CapNhatGiaSanPham
on PhieuNhapChiTiet
after insert
as
begin
    declare @MaSP CHAR(10), @DonGiaNhap DECIMAL(10, 2), @NgayNhap DATE

	-- lay thong tin tu bang ghi  trong PhieuNhapChiTiet và PhieuNhap
    select @MaSP = i.MaSP, @DonGiaNhap = i.DonGiaNhap, @NgayNhap = p.NgayNhap
    from inserted i JOIN PhieuNhap p on i.MaPN = p.MaPN

	-- cap nhap ngay ket thuc cua gia cu, ngay ket thuc la ngay truoc ngay nhap 
    UPDATE GiaSanPham
    set NgayKetThuc = DATEADD(DAY, -1, @NgayNhap)  -- Nngay ket thuc la ngay truoc ngay nhap
    where MaSP = @MaSP and (NgayKetThuc IS NULL OR NgayKetThuc > @NgayNhap)

	-- them gia moi cho san pham voi ngay ap dung la ngay nhap va ngay ket thuc chua xac dinh la null 
    insert into GiaSanPham (MaGiaSanPham, Gia, NgayApDung, NgayKetThuc, MaSP, MaPNCT)
    values (
        'GSP' + RIGHT('000000' + CAST((select COUNT(*) + 1 from GiaSanPham) AS VARCHAR(6)), 6),
        @DonGiaNhap * 1.4,  
        @NgayNhap,
         DATEADD(MonTH, 6, GETDATE()),  
        @MaSP,
        (select TOP 1 MaPNCT from inserted)  
    )
end
go
--test
insert into PhieuNhapChiTiet (MaPNCT, SoLuongNhap,  DonGiaNhap, MaSP,MaPN)
values ('PNCT111112', 100,60000,'SP00000002','PN00000732')
insert into PhieuNhap (MaPN, NgayNhap) 
values ('PN00000732', '2024-10-18')
select * from GiaSanPham where MaSP = 'SP00000002'

select * from PhieuNhap where MaPN='PN00000732'
select * from PhieuNhapChiTiet where MaPN='PN00000732'

select * from PhieuNhapChiTiet where MaSP = 'SP00000002'

select * from PhieuNhapChiTiet 
select * from GiaSanPham

--cau2 Trigger cập nhật số lượng sản phẩm sau khi bán hàng
go
create or alter trigger capNhatSoLuongSauKhiBanHang
on DonBanHangChiTiet
after insert
as
begin
    
    UPDATE SanPham
    set SanPham.SoLuong = SanPham.SoLuong - inserted.SoLuong
    from SanPham JOIN inserted on SanPham.MaSP = inserted.MaSP
end
-- test
insert into DonBanHangChiTiet (MaDHCT, SoLuong, DonGia, DVT, MaSP,MaDH)
values ('DHCT002101', '3','830.00',N'Cái','SP00000443','DH00000617' )
       
select * from SanPham
where MaSP = 'SP00000443'

select * from DonBanHangChiTiet 
where MaSP = 'SP00000443'

--cau3 Trigger cập nhật số lượng sản phẩm sau khi nhập hàng
go 
create or alter trigger capNhatSoLuongSauKhiNhapHang
on PhieuNhapChiTiet
after insert
AS
begin
    UPDATE SanPham
    set SoLuong = SoLuong + inserted.SoLuongNhap
    from inserted 
    where SanPham.MaSP = inserted.MaSP
end
--TEST
insert into PhieuNhapChiTiet (MaPNCT, SoLuongNhap,DonGiaNhap, MaSP, MaPN)
values ('PNCT002800', 8,'626.00','SP00000695', 'PN00000732')

select * from SanPham
where MaSP = 'SP00000695'
select * from PhieuNhapChiTiet
where MaSP = 'SP00000695'

--4 Hàm kiểm tra sự tồn tại của khách hàng
go
create or alter function kiemTraKhachHangTonTai(@TenKhachHang NVARCHAR(50), @SoDienThoai char(10))
returnS BIT
AS
begin
    IF EXISTS (select 1 from KhachHang where TenKH = @TenKhachHang AND SDTKH = @SoDienThoai)
        return 1
    return 0
end;

select dbo.kiemTraKhachHangTonTai (N'Khách hàng 1','0869894983') 

select * from KhachHang
--5Hàm kiểm tra sự tồn tại của sản phẩm
go
create function kiemtraSanPhamTonTai (@MaSP char(10))
returns bit
as
begin
    if exists (select 1 from SanPham where MaSP = @MaSP)
        return 1;  
    return 0 
end
-- goi ham
select dbo.kiemtraSanPhamTonTai('SP00000001') as KiemTra

select dbo.kiemtraSanPhamTonTai('SP00001001') as KiemTra


--6 Hàm tính tổng tiền phiếu nhập hàng
go
create or alter function fn_TongTienPhieuNhap (@MaPN CHAR(10))
returnS NUMERIC(20,0)
AS
begin
    declare @TongTien NUMERIC(20,0)
    
    select @TongTien = SUM(SoLuongNhap * DonGiaNhap)
    from PhieuNhapChiTiet
    where MaPN = @MaPN
    
    return @TongTien
end;
--Test:
go
select dbo.fn_TongTienPhieuNhap('PN00000732') AS TongTien

select * from PhieuNhapChiTiet
where MaPN = 'PN00000732' 
-- 7 Thủ tục tính tổng tiền đơn hàng
go
CREATE OR ALTER PROCEDURE sp_TinhTongTienDonHang
    @DonHangID char(10),                -- ID của đơn hàng
    @LoaiDonHang BIT,					-- Loại đơn hàng (0: Offline, 1: Online)
    @KhoangCach NUMERIC(5, 2),			-- Khoảng cách giao hàng (km)
    @TongTien NUMERIC(15, 0) OUTPUT		
AS
BEGIN
    DECLARE @TongTienHang NUMERIC(15, 0);  -- Tổng tiền hàng
    DECLARE @PhiVanChuyen NUMERIC(10, 0);  -- Phí vận chuyển

    -- 1. Tính tổng tiền hàng từ chi tiết đơn hàng
    SELECT @TongTienHang = SUM(SoLuong * DonGia)
    FROM DonBanHangChiTiet
    WHERE MaDH = @DonHangID;

    -- 2. Tính phí vận chuyển bằng cách gọi thủ tục sp_TinhPhiVanChuyen
    EXEC sp_TinhPhiVanChuyen @LoaiDonHang, @KhoangCach, @PhiVanChuyen OUTPUT;

    -- 3. Tính tổng tiền đơn hàng (bao gồm tổng tiền hàng và phí vận chuyển)
    SET @TongTien = @TongTienHang + @PhiVanChuyen;

    -- Trả về kết quả

    PRINT N'Tổng tiền hàng: ' + CAST(@TongTienHang AS NVARCHAR(20)) + ' VNĐ';
    PRINT N'Tổng tiền đơn hàng: ' + CAST(@TongTien AS NVARCHAR(20)) + ' VNĐ';

END;
GO
DECLARE @TongTien NUMERIC(15, 0);

EXEC sp_TinhTongTienDonHang
    @DonHangID = 'DH00000003',           
    @LoaiDonHang = 1,				
    @KhoangCach = 10,         
    @TongTien = @TongTien OUTPUT

select * from DonBanHang

--8. Hàm tính mã đơn hàng mới:
go
create or alter function fn_maDHMoi()
returns varchar(10)
as
begin
	declare @maDH int, @maDHMoi varchar(10)
	select @maDH = RIGHT(max(MaDH),8)
	from DonBanHang
	set @maDHMoi = 'DH' +  REPLICATE('0', 8 - LEN(@maDH + 1)) +convert(varchar, @maDH + 1)
	return @maDHMoi
end
go
select dbo.fn_maDHMoi()

--9. Hàm tính mã sản phẩm mới
go
create or alter function f_maSanPhamMoi()
returns varchar(10)
as
begin
	declare @maMax int, @maMoi varchar(10)
	select @maMax = RIGHT(max(MaSP),8)
	from SanPham
	set @maMoi = 'SP' +  REPLICATE('0', 8 - LEN(@maMax + 1)) +convert(varchar, @maMax + 1)
	return @maMoi
end
go
select dbo.f_maSanPhamMoi()

--10. Hàm tính mã phiếu nhập hàng mới:
go
create or alter function fn_maPNMoi()
returns varchar(10)
as
begin
	declare @maPN int, @maPNMoi varchar(10)
	select @maPN = RIGHT(max(MaPN),8)
	from PhieuNhap
	set @maPNMoi = 'PN' +  REPLICATE('0', 8 - LEN(@maPN + 1)) +convert(varchar, @maPN + 1)
	return @maPNMoi
end
go
select dbo.fn_maPNMoi()

--12. Hàm tính mã phiếu khách hàng mới:
go
create or alter function f_maKhachHangMoi()
returns varchar(10)
as
begin
	declare @maMax int, @maMoi varchar(10)
	select @maMax = RIGHT(max(MaKH),8)
	from KhachHang
	set @maMoi = 'KH' +  REPLICATE('0', 8 - LEN(@maMax + 1)) +convert(varchar, @maMax + 1)
	return @maMoi
end
go
select dbo.f_maKhachHangMoi()

--13. Thủ tục tính phí giao hàng
go
create or alter proc sp_TinhPhiVanChuyen
    @LoaiDonHang BIT,       
    @KhoangCach NUMERIC(5, 2),  
    @PhiVanChuyen NUMERIC(10, 0) OUTPUT 
AS
begin
    
    IF @LoaiDonHang = 0
    begin
        set @PhiVanChuyen = 0
    end
    else
    begin
        
        IF @KhoangCach < 5
        begin
            set @PhiVanChuyen = 0
        end
        else
        begin
            set @PhiVanChuyen = 30000
        end
    end
    
    print N'Phi van chuyen: ' + CAST(@PhiVanChuyen AS NVARCHAR(20)) + ' VND'
    return @PhiVanChuyen
end;
go
declare @PhiVanChuyen NUMERIC(10, 0)
exec sp_TinhPhiVanChuyen @LoaiDonHang = 1, @KhoangCach = 10, @PhiVanChuyen = @PhiVanChuyen OUTPUT
--14 . Thủ tục cập nhật tình trạng giao hàng
go
CREATE TABLE LichSuTrangThaiDonHang ( MaDH CHAR(10),
										TrangThai NVARCHAR(50),
										ThoiGianCapNhat DATETIME,
										PRIMARY KEY (MaDH, ThoiGianCapNhat)
									  )
go
create or alter proc CapNhatTrangThaiGiaoHang
    @MaDH CHAR(10),
    @TrangThaiMoi NVARCHAR(50)
AS
begin
    declare @TrangThaiHienTai NVARCHAR(50)

    --lay trang thai don hang hien tai
    select @TrangThaiHienTai = TrangThaiDonHang
    from DonBanHang
    where MaDH = @MaDH

    -- neu trang thai hien tai là da giao, khong cho phép cap nhap thanh chua giao'
    IF @TrangThaiHienTai = N'Đã giao' AND @TrangThaiMoi = N'Chưa giao'
    begin
        print (N'khong the thay doi trang thai tu da giao thanh chua giao')
        return
    end

    -- cap nhap trang thai trong bang chinh
    UPDATE DonBanHang
    set TrangThaiDonHang = @TrangThaiMoi
    where MaDH = @MaDH

    -- luu lai lich su cap nhap trang thai
    insert into LichSuTrangThaiDonHang (MaDH, TrangThai, ThoiGianCapNhat)
    values (@MaDH, @TrangThaiMoi, GETDATE())
end
--goi thu tuc
go
exec CapNhatTrangThaiGiaoHang @MaDH = 'DH00000002', @TrangThaiMoi = N'Đã giao'

exec CapNhatTrangThaiGiaoHang @MaDH = 'DH00000002', @TrangThaiMoi = N'Chưa giao'

select * from DonBanHang
where MaDH = 'DH00000002'

exec CapNhatTrangThaiGiaoHang @MaDH = 'DH00000001', @TrangThaiMoi = N'Chưa giao'
select * from DonBanHang
where MaDH = 'DH00000001'