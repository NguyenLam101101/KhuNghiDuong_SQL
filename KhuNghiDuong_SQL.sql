USE [khunghiduong]
GO
/****** Object:  UserDefinedFunction [dbo].[fu_CHIPHIND]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fu_CHIPHIND](
@MaPDK INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TienP MONEY,
	        @TienGND MONEY,
			@KhuyenMai decimal(3,2);
	SELECT @TienP = SUM(D.SoLuong * C.GiaLP) 
	FROM PHIEUDANGKY P, DKLOAIPHONG D, CCLOAIPHONG C
    WHERE D.MaPDK = P.MaPDK AND P.MaPDK = @MaPDK AND C.MaKND = P.MaKND AND D.MaLP = C.MaLP;
	SET @TienGND = (
	SELECT GiaGND*SoNguoiLon
	FROM PHIEUDANGKY P, GOINGHIDUONG G
	WHERE P.MaGND = G.MaGND AND P.MaPDK = @MaPDK);
	SET @KhuyenMai = (SELECT ChietKhau FROM KHUYENMAI K, PHIEUDANGKY P WHERE P.MaKM = K.MaKM AND P.MaPDK = @MaPDK)
	IF @KhuyenMai IS NULL
	    SET @KhuyenMai = 1
    RETURN (@TienP + @TienGND)*@KhuyenMai
END
GO
/****** Object:  UserDefinedFunction [dbo].[fu_DOANHTHU]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fu_DOANHTHU](
@MaKND NCHAR(10),
@NgayBD DATE,
@NgayKT DATE)
RETURNS MONEY
AS
BEGIN
     DECLARE @TienHD INT,
	        @TienHP INT;
	SET @TienHD = (
    SELECT SUM(TongTien)
    FROM HOADON H, PHIEUDANGKY P
    WHERE H.ThoiGian >= @NgayBD AND H.ThoiGian <= @NgayKT AND H.MaPDK = P.MaPDK AND P.MaKND = @MaKND);
	IF @TienHD IS NULL
	    SET @TienHD = 0;
	SET @TienHP = (
	SELECT SUM(PhiHP)
	FROM PHIEUHUYPHONG
	WHERE MaKND = @MaKND AND ThoiGian >= @NgayBD AND ThoiGian <= @NgayKT);
	IF @TienHP IS NULL
	    SET @TienHP = 0;
	RETURN @TienHD + @TienHP;
END
GO
/****** Object:  UserDefinedFunction [dbo].[fu_MONEY_KH]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Hiển thị những khu nghỉ dưỡng được đăng ký nhiều nhất trong 1 khoảng thời gian*/

Create function [dbo].[fu_MONEY_KH](
@MaKH INT,
@NgayBD DATE,
@NgayKT DATE)
RETURNS MONEY
AS
BEGIN
    RETURN(
	SELECT SUM(TongTien)
	FROM HOADON H, PHIEUDANGKY P, KHACHHANG K
	WHERE H.MaPDK = P.MaPDK AND P.MaKH = K.MaKH AND K.MaKH = @MaKH AND H.ThoiGian >= @NgayBD AND H.ThoiGian <= @NgayKT)
END
GO
/****** Object:  UserDefinedFunction [dbo].[fu_PHIHP]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Function [dbo].[fu_PHIHP] (
@MaPDK INT,
@NgayH DATE)
Returns money
as
Begin
	DECLARE @CHENHLECH INT,
			@NGAYDEN DATE;
	SET @NGAYDEN = (SELECT NgayDen FROM PHIEUDANGKY WHERE MaPDK = @MaPDK);
	SET @CHENHLECH = DATEDIFF(DAY,@NgayH,@NGAYDEN);
	IF @CHENHLECH > 10
	    RETURN 0;
	IF @CHENHLECH >= 7 AND @CHENHLECH <=10
	    RETURN 0.5 * dbo.fu_CHIPHIND(@MaPDK);
	RETURN dbo.fu_CHIPHIND(@MaPDK);
end
GO
/****** Object:  UserDefinedFunction [dbo].[fu_SOHD]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fu_SOHD](
@MaKND nchar(10),
@GTMin money,
@GTMax money,
@NgayBD date,
@NgayKT date)
returns int
as 
begin
    return (select count(MaHD) 
	from HOADON h, PHIEUDANGKY p
	where h.MaPDK = p.MaPDK and p.MaKND = @MaKND and h.ThoiGian >= @NgayBD and h.ThoiGian <= @NgayKT and h.TongTien >= @GTMin and h.TongTien <= @GTMax);		
end
GO
/****** Object:  UserDefinedFunction [dbo].[fu_SOKH]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*Hiển thị số khách hàng của 1 khu nghỉ dưỡng trong 1 khoảng thời gian*/

Create FUNCTION [dbo].[fu_SOKH] (@MaKND nchar(10), @t1 date, @t2 date)
RETURNs INT
AS
BEGIN
	Declare @soKH INT
	select @soKH = SUM(SoNguoiLon) + SUM(SoTreEm)
	from PHIEUDANGKY
	where MaKND = @MaKND AND Thoigian BETWEEN @t1 AND @t2
	return @soKH
END

GO
/****** Object:  UserDefinedFunction [dbo].[fu_SOPDK]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [dbo].[fu_SOPDK] (@MaKND nchar(10), @t1 date, @t2 date)
RETURNs INT
AS
Begin
	Declare @so_PDK INT
	select @so_PDK = count(MaPDK) 
	from PHIEUDANGKY
	where MaKND = @MaKND AND Thoigian BETWEEN @t1 AND @t2
	return @so_PDK
End

GO
/****** Object:  UserDefinedFunction [dbo].[fu_SOPHONGCHUADK]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fu_SOPHONGCHUADK](
@MaKND NCHAR(10),
@MaLP NCHAR(10),
@ThoiGian DATE)
RETURNS INT
AS 
BEGIN 
    DECLARE @tongp INT,
	        @tongpdk INT;
    SET @tongp = (
	SELECT COUNT(MaP)
	FROM PHONG P
	WHERE MaKND = @MaKND AND MaLP = @MaLP)
	SET @tongpdk = (
	SELECT SUM(SoLuong)
	FROM DKLOAIPHONG D, PHIEUDANGKY P
	WHERE MaKND = @MaKND AND MaLP = @MaLP AND D.MaPDK = P.MaPDK AND NgayDen <= @ThoiGian AND NgayDi > @ThoiGian)
	IF @tongpdk IS NULL
	    SET @tongpdk = 0
	RETURN (@tongp - @tongpdk)
END





GO
/****** Object:  UserDefinedFunction [dbo].[fu_THANHTIENHD]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fu_THANHTIENHD](
@MaHD INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @MaPDK int,
	        @tongtien money,
			@phuthu MONEY;
    SET @MaPDK = (select MaPDK from HOADON WHERE MaHD = @MaHD);
	SET @tongtien = dbo.fu_CHIPHIND(@MaPDK);
	SET @phuthu = (SELECT SUM(SoTien) FROM PHUTHU WHERE MaHD = @MaHD);
	IF @phuthu IS NOT NULL
	    SET @tongtien = @tongtien + @phuthu;
	RETURN @tongtien;
END

	
GO
/****** Object:  Table [dbo].[CCDICHVU]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CCDICHVU](
	[MaKND] [nchar](10) NOT NULL,
	[MaDV] [nchar](10) NOT NULL,
 CONSTRAINT [PK_CCDICHVU] PRIMARY KEY CLUSTERED 
(
	[MaKND] ASC,
	[MaDV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CCGOINGHIDUONG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CCGOINGHIDUONG](
	[MaKND] [nchar](10) NOT NULL,
	[MaGND] [nchar](10) NOT NULL,
 CONSTRAINT [PK_CCGOINGHIDUONG] PRIMARY KEY CLUSTERED 
(
	[MaKND] ASC,
	[MaGND] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CCKHUYENMAI]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CCKHUYENMAI](
	[MaKND] [nchar](10) NOT NULL,
	[MaKM] [nchar](10) NOT NULL,
 CONSTRAINT [PK_CCKHUYENMAI] PRIMARY KEY CLUSTERED 
(
	[MaKND] ASC,
	[MaKM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CCLOAIPHONG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CCLOAIPHONG](
	[MaKND] [nchar](10) NOT NULL,
	[MaLP] [nchar](10) NOT NULL,
	[GiaLP] [money] NOT NULL,
 CONSTRAINT [PK_CCLOAIPHONG] PRIMARY KEY CLUSTERED 
(
	[MaKND] ASC,
	[MaLP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CTHOADON]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTHOADON](
	[MaHD] [int] NOT NULL,
	[MaP] [nchar](10) NOT NULL,
 CONSTRAINT [PK_CTHOADON] PRIMARY KEY CLUSTERED 
(
	[MaHD] ASC,
	[MaP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DICHVU]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DICHVU](
	[MaDV] [nchar](10) NOT NULL,
	[TenDV] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DICHVU] PRIMARY KEY CLUSTERED 
(
	[MaDV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DKLOAIPHONG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DKLOAIPHONG](
	[MaPDK] [int] NOT NULL,
	[MaLP] [nchar](10) NOT NULL,
	[SoLuong] [int] NOT NULL,
 CONSTRAINT [PK_DKLOAIPHONG] PRIMARY KEY CLUSTERED 
(
	[MaPDK] ASC,
	[MaLP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GIAPT]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GIAPT](
	[MaKND] [nchar](10) NOT NULL,
	[MaGND] [nchar](10) NOT NULL,
	[TenPT] [nchar](10) NOT NULL,
	[GiaPT] [money] NOT NULL,
 CONSTRAINT [PK_GIAPT] PRIMARY KEY CLUSTERED 
(
	[MaKND] ASC,
	[MaGND] ASC,
	[TenPT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GOINGHIDUONG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GOINGHIDUONG](
	[MaGND] [nchar](10) NOT NULL,
	[TenGND] [nvarchar](50) NOT NULL,
	[GiaGND] [money] NOT NULL,
	[ChiTiet] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_GOINGHIDUONG] PRIMARY KEY CLUSTERED 
(
	[MaGND] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HOADON]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HOADON](
	[MaHD] [int] IDENTITY(1,1) NOT NULL,
	[MaNV] [int] NOT NULL,
	[MaPDK] [int] NOT NULL,
	[TongTien] [money] NULL,
	[ThoiGian] [date] NULL,
	[TGCheck-in] [time](7) NOT NULL,
	[TGCheck-out] [time](7) NOT NULL,
	[SoNguoiLon] [int] NULL,
	[SoTreEm] [int] NULL,
	[HinhThucTT] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_HOADON] PRIMARY KEY CLUSTERED 
(
	[MaHD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KHACHHANG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KHACHHANG](
	[MaKH] [int] IDENTITY(1,1) NOT NULL,
	[HoTenKH] [nvarchar](50) NOT NULL,
	[SĐT] [nchar](15) NOT NULL,
	[CMND/CCCD/HC] [nchar](15) NOT NULL,
	[Email] [nvarchar](50) NULL,
	[QuocGia] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_KHACHHANG] PRIMARY KEY CLUSTERED 
(
	[MaKH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KHUNGHIDUONG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KHUNGHIDUONG](
	[MaKND] [nchar](10) NOT NULL,
	[TenKND] [nvarchar](50) NOT NULL,
	[DiaChi] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_KHUNGHIDUONG] PRIMARY KEY CLUSTERED 
(
	[MaKND] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KHUYENMAI]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KHUYENMAI](
	[MaKM] [nchar](10) NOT NULL,
	[TenKM] [nvarchar](200) NOT NULL,
	[DieuKien] [nvarchar](200) NOT NULL,
	[ChietKhau] [decimal](3, 2) NOT NULL,
	[NgayBD] [date] NOT NULL,
	[NgayKT] [date] NOT NULL,
 CONSTRAINT [PK_KHUYENMAI] PRIMARY KEY CLUSTERED 
(
	[MaKM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LOAIPHONG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LOAIPHONG](
	[MaLP] [nchar](10) NOT NULL,
	[TenLP] [nvarchar](50) NOT NULL,
	[SoNguoiLon] [int] NOT NULL,
	[SoTreEm] [int] NOT NULL,
 CONSTRAINT [PK_LOAIPHONG] PRIMARY KEY CLUSTERED 
(
	[MaLP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NHANVIEN]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NHANVIEN](
	[MaNV] [int] IDENTITY(1,1) NOT NULL,
	[HoTenNV] [nvarchar](50) NOT NULL,
	[GioiTinh] [nvarchar](10) NOT NULL,
	[NgaySinh] [date] NOT NULL,
 CONSTRAINT [PK_NHANVIEN] PRIMARY KEY CLUSTERED 
(
	[MaNV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PHIEUDANGKY]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PHIEUDANGKY](
	[MaPDK] [int] IDENTITY(1,1) NOT NULL,
	[MaKH] [int] NOT NULL,
	[MaNV] [int] NOT NULL,
	[MaKND] [nchar](10) NOT NULL,
	[MaGND] [nchar](10) NOT NULL,
	[ThoiGian] [date] NOT NULL,
	[TienDat] [money] NOT NULL,
	[NgayDen] [date] NOT NULL,
	[NgayDi] [date] NOT NULL,
	[SoNguoiLon] [int] NOT NULL,
	[SoTreEm] [int] NOT NULL,
	[MaKM] [nchar](10) NULL,
 CONSTRAINT [PK_PHIEUDANGKY] PRIMARY KEY CLUSTERED 
(
	[MaPDK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PHIEUHUYPHONG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PHIEUHUYPHONG](
	[MaPHP] [int] IDENTITY(1,1) NOT NULL,
	[MaKND] [nchar](10) NOT NULL,
	[MaKH] [int] NOT NULL,
	[MaNV] [int] NOT NULL,
	[PhiHP] [money] NOT NULL,
	[ThoiGian] [date] NOT NULL,
 CONSTRAINT [PK_PHIEUHUYPHONG] PRIMARY KEY CLUSTERED 
(
	[MaPHP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PHONG]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PHONG](
	[MaP] [nchar](10) NOT NULL,
	[MaKND] [nchar](10) NOT NULL,
	[MaLP] [nchar](10) NOT NULL,
	[SoP] [nchar](10) NOT NULL,
	[TrangThai] [bit] NOT NULL,
 CONSTRAINT [PK_PHONG] PRIMARY KEY CLUSTERED 
(
	[MaP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PHUTHU]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PHUTHU](
	[MaHD] [int] NOT NULL,
	[TenPT] [nvarchar](50) NOT NULL,
	[SoTien] [money] NOT NULL,
 CONSTRAINT [PK_PHUTHU] PRIMARY KEY CLUSTERED 
(
	[MaHD] ASC,
	[TenPT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[fu_CTPHIEUDANGKY]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fu_CTPHIEUDANGKY](
@MaPDK INT)
RETURNS TABLE
AS
RETURN 
    SELECT P.MaPDK, HoTenKH, HoTenNV, ThoiGian, TenKND, TenGND, TenLP, SoLuong, NgayDen, NgayDi, TienDat, P.SoNguoiLon, P.SoTreEm
    FROM PHIEUDANGKY P, KHACHHANG KH, NHANVIEN N, KHUNGHIDUONG KN, GOINGHIDUONG G, DKLOAIPHONG D, LOAIPHONG L
    WHERE P.MaKH = KH.MaKH AND P.MaNV = N.MaNV AND P.MaKND = KN.MaKND AND P.MaGND = G.MaGND AND D.MaPDK = @MaPDK AND D.MaLP = L.MaLP AND P.MaPDK = @MaPDK
GO
/****** Object:  UserDefinedFunction [dbo].[fu_TIMKND]    Script Date: 10/27/2021 12:32:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fu_TIMKND](
@DiaChi NVARCHAR(20),
@MaGND nchar(10),
@MaDV nchar(10),
@MaLP nchar(10))
RETURNS TABLE
AS 
RETURN
    SELECT * FROM KHUNGHIDUONG 
	WHERE (@DiaChi = '' OR CHARINDEX(@DiaChi, TenKND, 1) > 0 OR CHARINDEX(@DiaChi, DiaChi, 1) > 0)
	AND (@MaGND = '' OR MaKND IN (SELECT MaKND FROM CCGOINGHIDUONG WHERE MaGND = @MaGND))
	AND (@MaDV = '' OR MaKND IN (SELECT MaKND FROM CCDICHVU WHERE MaDV = @MaDV))
	AND (@MaLP = '' OR MaKND IN (SELECT MaKND FROM CCLOAIPHONG WHERE MaLP = @MaLP))




		    
GO
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VCRDN     ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VCRDN     ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VCRDN     ', N'Par       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VCRDN     ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VCRDN     ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VCRDN     ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDGPQ     ', N'Bea       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDGPQ     ', N'BeaS      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDGPQ     ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDGPQ     ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDGPQ     ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDGPQ     ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDSNT     ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDSNT     ', N'Bea       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDSNT     ', N'BeaS      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDSNT     ', N'DivC      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDSNT     ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDSNT     ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VDSNT     ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHFPQ     ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHFPQ     ', N'Par       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHFPQ     ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHFPQ     ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHH       ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHH       ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHH       ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHH       ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHH       ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHRHP     ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHRHP     ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHRHP     ', N'Par       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHRHP     ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VHRHP     ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLL81     ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLL81     ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLL81     ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLL81     ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLL81     ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLNT      ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLNT      ', N'Bea       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLNT      ', N'BeaS      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLNT      ', N'DivC      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLNT      ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLNT      ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLNT      ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VLNT      ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VOPQ      ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VOPQ      ', N'BeaS      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VOPQ      ', N'Cas       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VOPQ      ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VOPQ      ', N'ShoS      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VOPQ      ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VOPQ      ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGNHA    ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGNHA    ', N'Bea       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGNHA    ', N'Gol       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGNHA    ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGNHA    ', N'Par       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGNHA    ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGNHA    ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGNHA    ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGPQ     ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGPQ     ', N'Bea       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGPQ     ', N'Gol       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGPQ     ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGPQ     ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRGPQ     ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSNTB    ', N'Bea       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSNTB    ', N'BeaS      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSNTB    ', N'ChiC      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSNTB    ', N'DivC      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSNTB    ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSNTB    ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSNTB    ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSNTB    ', N'SwiP      ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSPQ     ', N'Bar       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSPQ     ', N'Bea       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSPQ     ', N'Gym       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSPQ     ', N'Res       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSPQ     ', N'Spa       ')
INSERT [dbo].[CCDICHVU] ([MaKND], [MaDV]) VALUES (N'VRSPQ     ', N'SwiP      ')
GO
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VCRDN     ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VCRDN     ', N'BV        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VDGPQ     ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VDGPQ     ', N'BX        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VDGPQ     ', N'FB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VDGPQ     ', N'FX        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VDSNT     ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VDSNT     ', N'BV        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VDSNT     ', N'FB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VDSNT     ', N'FV        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VHFPQ     ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VHFPQ     ', N'FV        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VHFPQ     ', N'RO        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VHH       ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VHRHP     ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VLL81     ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VLL81     ', N'HB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VLNT      ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VLNT      ', N'BV        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VOPQ      ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VOPQ      ', N'BX        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VOPQ      ', N'FB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VOPQ      ', N'FX        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRGNHA    ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRGNHA    ', N'FB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRGNHA    ', N'FV        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRGPQ     ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRGPQ     ', N'BX        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRGPQ     ', N'FB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRGPQ     ', N'FX        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRSNTB    ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRSNTB    ', N'BV        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRSNTB    ', N'FB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRSNTB    ', N'FX        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRSPQ     ', N'BB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRSPQ     ', N'BX        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRSPQ     ', N'FB        ')
INSERT [dbo].[CCGOINGHIDUONG] ([MaKND], [MaGND]) VALUES (N'VRSPQ     ', N'FX        ')
GO
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VCRDN     ', N'HVRR2     ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VCRDN     ', N'HVRR2DS   ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VDGPQ     ', N'KTGW      ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VDSNT     ', N'HCD       ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VDSNT     ', N'HCDDS     ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VDSNT     ', N'UDDS8     ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VHFPQ     ', N'KTGW      ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VHH       ', N'HVRR      ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VHH       ', N'HVRRDS    ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VHH       ', N'UDDS10    ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VHRHP     ', N'HRR       ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VLL81     ', N'HVRR      ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VLL81     ', N'HVRRDS    ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VLNT      ', N'HCD       ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VLNT      ', N'HCDDS     ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VLNT      ', N'UDDS8     ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VOPQ      ', N'KTGW      ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VRGNHA    ', N'HVRR2     ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VRGNHA    ', N'HVRR2DS   ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VRGPQ     ', N'KTGW      ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VRSNTB    ', N'HCD       ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VRSNTB    ', N'HCDDS     ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VRSNTB    ', N'UDDS8     ')
INSERT [dbo].[CCKHUYENMAI] ([MaKND], [MaKM]) VALUES (N'VRSPQ     ', N'KTGW      ')
GO
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VCRDN     ', N'ESK       ', 1494000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VCRDN     ', N'ESKRV     ', 1881000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VCRDN     ', N'SK        ', 1233000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VCRDN     ', N'ST        ', 1233.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VDGPQ     ', N'V2B       ', 4384000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VDGPQ     ', N'V3B       ', 6576000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VDGPQ     ', N'V4B       ', 8760000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VDSNT     ', N'V2BPV     ', 6048000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VDSNT     ', N'V3BB      ', 10388000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VDSNT     ', N'V3BPV     ', 8568000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHFPQ     ', N'SK        ', 960000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHFPQ     ', N'SS        ', 1780000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHFPQ     ', N'ST        ', 960000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHH       ', N'DK        ', 1454000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHH       ', N'DT        ', 1454000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHRHP     ', N'BKPV      ', 2118000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHRHP     ', N'BTPV      ', 2118000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHRHP     ', N'DK        ', 1814000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VHRHP     ', N'DT        ', 1814000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLL81     ', N'CK        ', 3410000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLL81     ', N'CT        ', 3410000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLL81     ', N'PK        ', 2385000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLL81     ', N'PT        ', 2385000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLNT      ', N'PHTB      ', 7084000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLNT      ', N'PHTG      ', 5145000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLNT      ', N'PHTP      ', 6174000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLNT      ', N'PKB       ', 7084000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLNT      ', N'PKG       ', 5145000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VLNT      ', N'PKP       ', 6174000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VOPQ      ', N'JS        ', 2912000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VOPQ      ', N'SK        ', 2080000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VOPQ      ', N'ST        ', 2080000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGNHA    ', N'DK        ', 2948000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGNHA    ', N'DKOV      ', 3457000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGNHA    ', N'DT        ', 2948000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGNHA    ', N'DTOV      ', 3457000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGNHA    ', N'V3B       ', 10108000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGPQ     ', N'DK        ', 2512000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGPQ     ', N'DKOV      ', 2768000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGPQ     ', N'DT        ', 2512000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGPQ     ', N'DTOV      ', 2768000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGPQ     ', N'V2B       ', 4960000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGPQ     ', N'V3B       ', 7400000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRGPQ     ', N'V4B       ', 9840000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSNTB    ', N'DK        ', 2646000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSNTB    ', N'DKOV      ', 3073000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSNTB    ', N'DT        ', 2646000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSNTB    ', N'DTOV      ', 3073000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSNTB    ', N'V2BPV     ', 8372000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSNTB    ', N'V3BPV     ', 11840000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSPQ     ', N'DK        ', 2448000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSPQ     ', N'DKOV      ', 2704000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSPQ     ', N'DT        ', 2448000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSPQ     ', N'DTOV      ', 2704000.0000)
INSERT [dbo].[CCLOAIPHONG] ([MaKND], [MaLP], [GiaLP]) VALUES (N'VRSPQ     ', N'V3B       ', 9330000.0000)
GO
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (1, N'VCRDN01   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (1, N'VCRDN02   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (1, N'VCRDN05   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (1, N'VCRDN06   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (2, N'VDGP01    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (3, N'VDGP02    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (4, N'VDSNT10   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (4, N'VDSNT13   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (5, N'VDSNT22   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (6, N'VDSNT24   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (7, N'VHFPQ01   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (7, N'VHFPQ02   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (8, N'VHH01     ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (8, N'VHH02     ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (8, N'VHH03     ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (8, N'VHH04     ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (9, N'VHRHP01   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (9, N'VHRHP02   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (9, N'VHRHP05   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (10, N'VLL8103   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (10, N'VLL8107   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (10, N'VLL8111   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (10, N'VLL8115   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (11, N'VLNT01    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (11, N'VLNT07    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (12, N'VLNT02    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (12, N'VLNT04    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (12, N'VLNT08    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (13, N'VOPQ01    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (13, N'VOPQ04    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (13, N'VOPQ07    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (13, N'VOPQ10    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (14, N'VOPQ01    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (14, N'VOPQ02    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (14, N'VOPQ03    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (15, N'VOPQ24    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (15, N'VOPQ27    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (15, N'VOPQ30    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (16, N'VRGNHA02  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (17, N'VRGPQ38   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (18, N'VRGPQ45   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (19, N'VRSNTB39  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (20, N'VRSNTB03  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (20, N'VRSNTB04  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (21, N'VRSPQ31   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (22, N'VRSPQ01   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (23, N'VRSPQ03   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (23, N'VRSPQ04   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (23, N'VRSPQ07   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (23, N'VRSPQ08   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (24, N'VDGP02    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (25, N'VDGP01    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (26, N'VDGP01    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (27, N'VDSNT01   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (27, N'VDSNT04   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (28, N'VDSNT01   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (29, N'VDSNT05   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (30, N'VLNT01    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (30, N'VLNT06    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (30, N'VLNT07    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (31, N'VOPQ10    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (31, N'VOPQ13    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (31, N'VOPQ16    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (32, N'VOPQ27    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (32, N'VOPQ30    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (33, N'VRGNHA17  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (33, N'VRGNHA21  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (33, N'VRGNHA25  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (33, N'VRGNHA29  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (36, N'VRSNTB40  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (37, N'VRSNTB37  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (37, N'VRSNTB39  ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (38, N'VDGP18    ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (39, N'VDSNT01   ')
INSERT [dbo].[CTHOADON] ([MaHD], [MaP]) VALUES (39, N'VDSNT04   ')
GO
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'Bar       ', N'Quầy Bar')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'Bea       ', N'Bãi biển')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'BeaS      ', N'Beauty Salon')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'Cas       ', N'Casino')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'ChiC      ', N'khu vui chơi trẻ em')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'DivC      ', N'Diving Club')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'Gol       ', N'Sân Golf')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'Gym       ', N'Phòng Gym')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'Par       ', N'Bãi để xe')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'Res       ', N'Nhà Hàng')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'ShoS      ', N'Shopping Store')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'Spa       ', N'Spa')
INSERT [dbo].[DICHVU] ([MaDV], [TenDV]) VALUES (N'SwiP      ', N'Bể bơi')
GO
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (1, N'ESK       ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (2, N'ESK       ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (2, N'ESKRV     ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (3, N'V2B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (4, N'V3B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (6, N'V2BPV     ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (7, N'V2BPV     ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (8, N'V3BPV     ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (9, N'SK        ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (9, N'SS        ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (10, N'SK        ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (10, N'ST        ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (11, N'DK        ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (11, N'DT        ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (12, N'BKPV      ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (12, N'BTPV      ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (14, N'PK        ', 4)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (15, N'PHTB      ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (16, N'PHTG      ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (16, N'PKB       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (17, N'JS        ', 4)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (18, N'JS        ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (18, N'SK        ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (18, N'ST        ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (19, N'ST        ', 3)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (20, N'DKOV      ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (22, N'V4B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (23, N'V2B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (24, N'V4B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (25, N'V2BPV     ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (26, N'DT        ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (26, N'DTOV      ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (27, N'V3B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (28, N'DK        ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (29, N'DT        ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (29, N'DTOV      ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (30, N'V3B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (31, N'V2B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (32, N'V2B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (33, N'V2BPV     ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (34, N'V2BPV     ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (35, N'V3BB      ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (36, N'PHTB      ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (36, N'PKP       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (38, N'JS        ', 3)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (39, N'ST        ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (40, N'DK        ', 4)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (41, N'V3B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (42, N'V2B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (43, N'V3BPV     ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (44, N'V2BPV     ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (45, N'V4B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (46, N'V2BPV     ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (47, N'ST        ', 3)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (48, N'PHTB      ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (48, N'PHTG      ', 2)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (49, N'V2B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (50, N'V3B       ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (51, N'V2BPV     ', 1)
INSERT [dbo].[DKLOAIPHONG] ([MaPDK], [MaLP], [SoLuong]) VALUES (52, N'PHTB      ', 3)
GO
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VCRDN     ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VCRDN     ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VCRDN     ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VCRDN     ', N'BV        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VCRDN     ', N'BV        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VCRDN     ', N'BV        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'BX        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'BX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'BX        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'FB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'FB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'FB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'FX        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'FX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDGPQ     ', N'FX        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'BV        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'BV        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'BV        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'FB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'FB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'FB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'FV        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'FV        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VDSNT     ', N'FV        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'FV        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'FV        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'FV        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'RO        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'RO        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHFPQ     ', N'RO        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHH       ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHH       ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHH       ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHRHP     ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHRHP     ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VHRHP     ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLL81     ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLL81     ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLL81     ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLL81     ', N'HB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLL81     ', N'HB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLL81     ', N'HB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLNT      ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLNT      ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLNT      ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLNT      ', N'BV        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLNT      ', N'BV        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VLNT      ', N'BV        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'BX        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'BX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'BX        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'FB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'FB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'FB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'FX        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'FX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VOPQ      ', N'FX        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'FB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'FB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'FB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'FV        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'FV        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGNHA    ', N'FV        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'BX        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'BX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'BX        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'FB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'FB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'FB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'FX        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'FX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRGPQ     ', N'FX        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'BV        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'BV        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'BV        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'FB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'FB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'FB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'FX        ', N'GP        ', 1500000.0000)
GO
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'FX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSNTB    ', N'FX        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'BB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'BB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'BB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'BX        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'BX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'BX        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'FB        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'FB        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'FB        ', N'TE        ', 1000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'FX        ', N'GP        ', 1500000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'FX        ', N'NL        ', 2000000.0000)
INSERT [dbo].[GIAPT] ([MaKND], [MaGND], [TenPT], [GiaPT]) VALUES (N'VRSPQ     ', N'FX        ', N'TE        ', 1000000.0000)
GO
INSERT [dbo].[GOINGHIDUONG] ([MaGND], [TenGND], [GiaGND], [ChiTiet]) VALUES (N'BB        ', N'Bed & Breakfast', 96000.0000, N'Gồm đêm nghỉ kèm theo 01 bữa ăn sáng')
INSERT [dbo].[GOINGHIDUONG] ([MaGND], [TenGND], [GiaGND], [ChiTiet]) VALUES (N'BV        ', N'Bed&Breakfast with VinWonders', 376000.0000, N'Gói Phòng BB kèm theo vui chơi không giới hạn tại VinWonders')
INSERT [dbo].[GOINGHIDUONG] ([MaGND], [TenGND], [GiaGND], [ChiTiet]) VALUES (N'BX        ', N'Bed&Breakfast with VinWonders + Safari', 584000.0000, N'Gói Phòng BB kèm theo vui chơi không giới hạn tại VinWonders và Vinpearl Safari')
INSERT [dbo].[GOINGHIDUONG] ([MaGND], [TenGND], [GiaGND], [ChiTiet]) VALUES (N'FB        ', N'Full-board', 1632.0000, N'Gồm đêm nghỉ kèm theo 03 bữa ăn: ăn tối ngày đến, ăn sáng và trưa ngày trả phòng')
INSERT [dbo].[GOINGHIDUONG] ([MaGND], [TenGND], [GiaGND], [ChiTiet]) VALUES (N'FV        ', N'Full-board with VinWonders', 1912000.0000, N'Gói Phòng BB kèm theo vui chơi không giới hạn tại VinWonders')
INSERT [dbo].[GOINGHIDUONG] ([MaGND], [TenGND], [GiaGND], [ChiTiet]) VALUES (N'FX        ', N'Full-board with VinWonders + Safari', 2120000.0000, N'Gói Phòng FB kèm theo vui chơi không giới hạn tại VinWonders và Vinpearl Safari')
INSERT [dbo].[GOINGHIDUONG] ([MaGND], [TenGND], [GiaGND], [ChiTiet]) VALUES (N'HB        ', N'Half-boad', 864000.0000, N'Gồm đêm nghỉ kèm theo 02 bữa ăn: ăn sáng và ăn trưa hoặc ăn tối theo lưa chọn của Khách')
INSERT [dbo].[GOINGHIDUONG] ([MaGND], [TenGND], [GiaGND], [ChiTiet]) VALUES (N'RO        ', N'Room Only', 0.0000, N'Chỉ gồm đêm nghỉ')
GO
SET IDENTITY_INSERT [dbo].[HOADON] ON 

INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (1, 4, 2, 21764000.0000, CAST(N'2020-11-01' AS Date), CAST(N'05:00:00' AS Time), CAST(N'12:00:00' AS Time), 7, 3, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (2, 13, 3, 6576000.0000, CAST(N'2021-01-26' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 3, 0, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (3, 16, 4, 9496000.0000, CAST(N'2021-04-18' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 5, 0, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (4, 10, 6, 22092000.0000, CAST(N'2020-08-26' AS Date), CAST(N'14:00:00' AS Time), CAST(N'13:00:00' AS Time), 7, 3, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (5, 4, 7, 11551264.0000, CAST(N'2021-03-06' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 4, 2, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (6, 14, 8, 23040000.0000, CAST(N'2020-08-19' AS Date), CAST(N'12:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 3, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (7, 6, 9, 6528000.0000, CAST(N'2021-03-29' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 4, 2, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (8, 17, 11, 9876000.0000, CAST(N'2020-10-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), 8, 3, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (9, 3, 12, 9930000.0000, CAST(N'2020-11-26' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 3, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (10, 18, 14, 19452000.0000, CAST(N'2021-02-23' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 8, 5, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (11, 1, 15, 19456000.0000, CAST(N'2020-07-06' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 4, 2, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (12, 14, 16, 32381000.0000, CAST(N'2020-12-24' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 4, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (13, 9, 17, 27832000.0000, CAST(N'2020-11-01' AS Date), CAST(N'14:00:00' AS Time), CAST(N'22:00:00' AS Time), 8, 5, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (14, 14, 18, 21152000.0000, CAST(N'2020-12-13' AS Date), CAST(N'05:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 1, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (15, 19, 19, 18960000.0000, CAST(N'2020-09-03' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 2, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (16, 14, 20, 6973500.0000, CAST(N'2020-10-13' AS Date), CAST(N'14:00:00' AS Time), CAST(N'13:00:00' AS Time), 2, 2, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (17, 2, 22, 15928000.0000, CAST(N'2021-02-03' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 8, 1, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (18, 16, 23, 7966528.0000, CAST(N'2020-12-21' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 4, 4, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (19, 4, 25, 10256000.0000, CAST(N'2020-12-24' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 4, 2, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (20, 17, 26, 5792900.0000, CAST(N'2021-06-29' AS Date), CAST(N'14:00:00' AS Time), CAST(N'13:00:00' AS Time), 3, 1, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (21, 19, 27, 13834000.0000, CAST(N'2021-01-15' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 3, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (22, 1, 28, 2451264.0000, CAST(N'2020-10-15' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 2, 3, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (23, 5, 29, 27664000.0000, CAST(N'2021-01-20' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 8, 4, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (24, 6, 30, 15304000.0000, CAST(N'2020-09-02' AS Date), CAST(N'14:00:00' AS Time), CAST(N'22:00:00' AS Time), 6, 4, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (25, 18, 31, 10580896.0000, CAST(N'2021-02-09' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), 4, 3, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (26, 5, 32, 11624000.0000, CAST(N'2021-03-09' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 3, 4, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (27, 11, 33, 13864000.0000, CAST(N'2020-11-19' AS Date), CAST(N'12:00:00' AS Time), CAST(N'12:00:00' AS Time), 8, 3, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (28, 19, 34, 20940000.0000, CAST(N'2021-03-06' AS Date), CAST(N'05:00:00' AS Time), CAST(N'13:00:00' AS Time), 4, 4, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (29, 16, 35, 19948000.0000, CAST(N'2020-09-20' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 5, 1, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (30, 17, 36, 21822000.0000, CAST(N'2021-01-29' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 5, 1, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (31, 21, 38, 11216000.0000, CAST(N'2020-07-10' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 2, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (32, 8, 39, 11824000.0000, CAST(N'2020-09-21' AS Date), CAST(N'05:00:00' AS Time), CAST(N'12:00:00' AS Time), 3, 1, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (33, 21, 40, 40764000.0000, CAST(N'2020-06-16' AS Date), CAST(N'14:00:00' AS Time), CAST(N'13:00:00' AS Time), 8, 4, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (34, 11, 41, 13964000.0000, CAST(N'2021-03-22' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 2, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (35, 4, 42, 14320000.0000, CAST(N'2020-07-23' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 3, 2, N'Tiền Mặt')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (36, 15, 43, 15416000.0000, CAST(N'2021-03-28' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 3, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (37, 3, 44, 22376000.0000, CAST(N'2021-02-22' AS Date), CAST(N'14:00:00' AS Time), CAST(N'12:00:00' AS Time), 7, 4, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (38, 16, 45, 40400000.0000, CAST(N'2020-12-23' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), 8, 4, N'Chuyển Khoản')
INSERT [dbo].[HOADON] ([MaHD], [MaNV], [MaPDK], [TongTien], [ThoiGian], [TGCheck-in], [TGCheck-out], [SoNguoiLon], [SoTreEm], [HinhThucTT]) VALUES (39, 13, 46, 5330400.0000, CAST(N'2021-05-05' AS Date), CAST(N'12:00:00' AS Time), CAST(N'12:00:00' AS Time), 7, 3, N'Tiền Mặt')
SET IDENTITY_INSERT [dbo].[HOADON] OFF
GO
SET IDENTITY_INSERT [dbo].[KHACHHANG] ON 

INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (1, N'Trịnh Văn Hùng', N'0335462981     ', N'VietNam        ', N'001203457698', N'tvh1982@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (2, N'Phạm Thị Thảo', N'0364008652     ', N'VietNam        ', N'005386003603', N'ptt86@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (3, N'Nguyễn Đình Bảo', N'0976749824     ', N'VietNam        ', N'0054800505', N'ndb62@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (4, N'Kaur Amajeet', N'02912345678    ', N'UK             ', N'G6468809', N'KaurA123@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (5, N'Nguyễn Văn Hoàng', N'0345987555     ', N'VietNam        ', N'001201701601', N'nvh88@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (6, N'Nguyễn Thị Yến', N'0346738774     ', N'VietNam        ', N'003684773668', N'nty89@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (7, N'Michelle Obama', N'055550100      ', N'USA            ', N'C76534934', N'MichelleO74@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (8, N'Đặng Minh Trang', N'0342678472     ', N'VietNam        ', N'001204018015', N'dmt01@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (9, N'Nguyễn Khắc Việt', N'0335083089     ', N'VietNam        ', N'003400809802', N'nkv2000@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (10, N'Vũ Thành Tâm', N'0364002997     ', N'VietNam        ', N'006700893473', N'vtt98@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (11, N'Tong Guangming', N'01012345678    ', N'China          ', N'E53695799', N'tgm80@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (12, N'Lê Văn Thành', N'0344896452     ', N'VietNam        ', N'006101234568', N'lvt77@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (13, N'Lê Thảo Phương', N'0182345678     ', N'VietNam        ', N'006583992003', N'ltp82@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (14, N'Nguyễn Thị Thảo Nguyên', N'0336987345     ', N'VietNam        ', N'004600304087', N'nttp01@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (15, N'Nguyễn Nhất Thành', N'0976987789     ', N'VietNam        ', N'003400689743', N'nnt92@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (16, N'Hwang Huiyeon', N'078355835      ', N'Korea          ', N'M75293609', N'HwangH@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (17, N'Phạm Phương Linh', N'0678354586     ', N'VietNam        ', N'005600340456', N'ppl99@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (18, N'Vũ Thành Huy', N'0473774342     ', N'VietNam        ', N'002375043570', N'vth60@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (19, N'Nguyễn Văn Kiên', N'0364046397     ', N'VietNam        ', N'006707843473', N'nvk98@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (20, N'Nguyễn Vũ Nguyên', N'0532702997     ', N'VietNam        ', N'003574375073', N'nvn98@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (21, N'Nguyễn Khắc Việt Hưng', N'0335088789     ', N'VietNam        ', N'003846009802', N'nkvh2000@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (22, N'Phạm Thị Tú', N'0364745752     ', N'VietNam        ', N'095386003603', N'ptt88@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (23, N'Trịnh Văn Quyết', N'0335498881     ', N'VietNam        ', N'001203000698', N'tvq1973@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (24, N'Đặng Vân Anh', N'0364662981     ', N'VietNam        ', N'001256459698', N'dva89@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (25, N'Kishi Kiochi', N'08873648333    ', N'Japan          ', N'TH9634785', N'KishiK456@gmail.com')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTenKH], [SĐT], [CMND/CCCD/HC], [Email], [QuocGia]) VALUES (26, N'Nguyễn Văn Kiên', N'0335460071     ', N'VietNam        ', N'001200047687', N'nvk82@gmail.com')
SET IDENTITY_INSERT [dbo].[KHACHHANG] OFF
GO
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VCRDN     ', N'Vinpearl Condotel Riverfront Da Nang', N'341 Duong Tran Hung Dao, Phuong An Hai Bac, Quan Son Tra, Thanh pho Da Nang')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VDGPQ     ', N'Vinpearl Discovery Greenhill Phu Quoc', N'Khu Bai Dai, Xa Ganh Dau, Huyen Phu Quoc, tinh Kien Giang')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VDSNT     ', N'Vinpearl Discovery Sealink Nha Trang', N'Dao Hon Tre, Tp. Nha Trang, Tinh Khanh Hoa')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VHFPQ     ', N'VinHolidays Fiesta Phu Quoc', N'Khu Bai Dai, Xa Ganh Dau, Huyen Phu Quoc, tinh Kien Giang')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VHH       ', N'Vinpearl Hotel Hue', N'50A Hung Vuong, Phuong Phu Nhuan, Thanh Pho Hue, Tinh Thua Thien Hue')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VHRHP     ', N'Vinpearl Hotel Rivera Hai Phong', N'Duong Manhattan 9, khu do thi Vinhomes Imperia, Hong Bang, Thanh pho Hai Phong')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VLL81     ', N'Vinpearl Luxury Landmark 81', N'Vinhomes Central Park, Quan Binh Thanh, Thanh pho Ho Chi Minh')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VLNT      ', N'Vinpearl Luxury Nha Trang', N'Dao Hon Tre, Tp. Nha Trang, Tinh Khanh Hoa')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VOPQ      ', N'VinOasis Phu Quoc', N'Khu Bai Dai, Xa Ganh Dau, Huyen Phu Quoc, tinh Kien Giang')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VRGNHA    ', N'Vinpearl Resort & Golf Nam Hoi An', N'Xa Binh Duong, Xa Binh Minh, Huyen Thang Binh, Tinh Quang Nam')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VRGPQ     ', N'Vinpearl Resort & Golf Phu Quoc', N'Khu Bai Dai, Xa Ganh Dau, Huyen Phu Quoc, Tinh Kien Giang')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VRSNTB    ', N'Vinpearl Resort & Spa Nha Trang Bay', N'Dao Hon Tre, Tp. Nha Trang, Tinh Khanh Hoa')
INSERT [dbo].[KHUNGHIDUONG] ([MaKND], [TenKND], [DiaChi]) VALUES (N'VRSPQ     ', N'Vinpearl Resort & Spa Phu Quoc', N'Khu Bai Dai, Xa Ganh Dau, Huyen Phu Quoc, Tinh Kien Giang')
GO
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'HCD       ', N'Hè Cực Đỉnh', N'Tất cả phòng và gói nghỉ dưỡng', CAST(0.20 AS Decimal(3, 2)), CAST(N'2021-05-01' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'HCDDS     ', N'Hè Cực Đỉnh - Đặt Sớm', N'Đặt sớm ít nhất 30 ngày', CAST(0.30 AS Decimal(3, 2)), CAST(N'2021-05-01' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'HRR       ', N'Hè Rực Rỡ', N'Đặt ít nhất 2 đêm nghỉ', CAST(0.10 AS Decimal(3, 2)), CAST(N'2021-05-01' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'HVRR      ', N'Hè Vui Rộn Rã', N'Tất cả phòng và dịch vụ', CAST(0.30 AS Decimal(3, 2)), CAST(N'2021-05-21' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'HVRR2     ', N'Hè Vui Rộn Rã 2', N'Tất cả phòng và dịch vụ', CAST(0.40 AS Decimal(3, 2)), CAST(N'2021-05-21' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'HVRR2DS   ', N'Hè Vui Rộn Rã 2 - Đặt Sớm', N'Đặt sớm ít nhất 30 ngày', CAST(0.44 AS Decimal(3, 2)), CAST(N'2021-05-21' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'HVRRDS    ', N'Hè Vui Rộn Rã - Đặt Sớm', N'Đặt sớm ít nhất 30 ngày', CAST(0.33 AS Decimal(3, 2)), CAST(N'2021-05-21' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'KTGW      ', N'Khai Trương Grand World', N'Tất cả gói phòng và nghỉ dưỡng', CAST(0.20 AS Decimal(3, 2)), CAST(N'2021-04-21' AS Date), CAST(N'2021-09-30' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'UDDS10    ', N'Ưu đãi đặt sớm 10%', N'Đặt sớm ít nhất 30 ngày', CAST(0.10 AS Decimal(3, 2)), CAST(N'2021-05-01' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[KHUYENMAI] ([MaKM], [TenKM], [DieuKien], [ChietKhau], [NgayBD], [NgayKT]) VALUES (N'UDDS8     ', N'Ưu Đãi Đặt Sớm 8%', N'Đặt sớm ít nhất 30 ngày', CAST(0.08 AS Decimal(3, 2)), CAST(N'2021-05-02' AS Date), CAST(N'2021-08-31' AS Date))
GO
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'BKPV      ', N'Business King Panoramic View', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'BTPV      ', N'Business Twin Panoramic View', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'CK        ', N'Club King', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'CT        ', N'Club Twin', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'DK        ', N'Deluxe King', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'DKOV      ', N'Deluxe King Ocean View', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'DT        ', N'Deluxe Twin', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'DTOV      ', N'Deluxe Twin Ocean View', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'ESK       ', N'Executive Suite King', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'ESKRV     ', N'Executive Suite King River View', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'JS        ', N'Junior Suite', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'PHTB      ', N'Premier Hollywood Twin Beachfront', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'PHTG      ', N'Premier Hollywood Twin Garden', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'PHTP      ', N'Premier Hollywood Twin Poolside', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'PK        ', N'Premier King', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'PKB       ', N'Premier King Beachfront', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'PKG       ', N'Premier King Garden', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'PKP       ', N'Premier King Poolside', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'PT        ', N'Premier Twin', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'SK        ', N'Standard King', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'SS        ', N'Studio Suite', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'ST        ', N'Standard Twin', 2, 2)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'V2B       ', N'Villa 2-Bedroom', 4, 4)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'V2BPV     ', N'Villa 2-Bedroom Pool View', 4, 4)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'V3B       ', N'Villa 3-Bedroom', 6, 6)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'V3BB      ', N'Villa 3-Bedroom Beachfront', 6, 6)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'V3BPV     ', N'Villa 3-Bedroom Pool View', 6, 6)
INSERT [dbo].[LOAIPHONG] ([MaLP], [TenLP], [SoNguoiLon], [SoTreEm]) VALUES (N'V4B       ', N'Villa 4-Bedroom', 8, 8)
GO
SET IDENTITY_INSERT [dbo].[NHANVIEN] ON 

INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (1, N'Nguyễn Hoàng Yến', N'N?', CAST(N'1989-06-04' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (2, N'Phạm Thị Huệ', N'N?', CAST(N'1995-03-23' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (3, N'Phạm Văn Quân', N'Nam', CAST(N'1992-04-17' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (4, N'Đặng Hồng Thu', N'N?', CAST(N'1993-03-11' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (5, N'Nguyễn Thị Minh', N'N?', CAST(N'1994-07-22' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (6, N'Nguyễn Thế Hoàng', N'Nam', CAST(N'1990-11-23' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (7, N'Phạm Gia Huy', N'Nam', CAST(N'1995-09-02' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (8, N'Nguyễn Hương Lan', N'N?', CAST(N'1994-06-08' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (9, N'Phạm Thị Huế', N'N?', CAST(N'1991-09-26' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (10, N'Trịnh Trung Hiếu', N'Nam', CAST(N'1990-12-23' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (11, N'Nguyễn Tuyết Hà', N'N?', CAST(N'1992-03-29' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (12, N'Nguyễn Ánh Nguyệt', N'N?', CAST(N'1993-06-08' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (13, N'Vũ Huy Thông', N'Nam', CAST(N'1989-09-04' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (14, N'Nguyễn Thị Nguyệt Hà', N'N?', CAST(N'1993-09-27' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (15, N'Nguyễn Thu Hương', N'N?', CAST(N'1996-07-03' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (16, N'Nguyễn Văn Hưng', N'Nam', CAST(N'1993-07-10' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (17, N'Hoàng Huy Nghĩa', N'Nam', CAST(N'1992-04-29' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (18, N'Nguyễn Thị Ngọc', N'N?', CAST(N'1996-08-16' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (19, N'Nguyễn Thị Hoa', N'N?', CAST(N'1994-09-04' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (20, N'Phạm Văn Đạt', N'Nam', CAST(N'1994-07-12' AS Date))
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTenNV], [GioiTinh], [NgaySinh]) VALUES (21, N'Nguyễn Thu Huệ', N'N?', CAST(N'1992-12-01' AS Date))
SET IDENTITY_INSERT [dbo].[NHANVIEN] OFF
GO
SET IDENTITY_INSERT [dbo].[PHIEUDANGKY] ON 

INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (1, 12, 4, N'VCRDN     ', N'BB        ', CAST(N'2021-06-17' AS Date), 1000000.0000, CAST(N'2021-08-01' AS Date), CAST(N'2021-08-06' AS Date), 3, 0, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (2, 14, 9, N'VCRDN     ', N'BV        ', CAST(N'2020-10-08' AS Date), 1000000.0000, CAST(N'2020-10-27' AS Date), CAST(N'2020-11-01' AS Date), 7, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (3, 11, 20, N'VDGPQ     ', N'BB        ', CAST(N'2020-12-13' AS Date), 1000000.0000, CAST(N'2021-01-24' AS Date), CAST(N'2021-01-26' AS Date), 2, 0, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (4, 9, 15, N'VDGPQ     ', N'BX        ', CAST(N'2021-03-27' AS Date), 1000000.0000, CAST(N'2021-04-13' AS Date), CAST(N'2021-04-18' AS Date), 5, 0, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (6, 22, 17, N'VDSNT     ', N'BV        ', CAST(N'2020-07-16' AS Date), 1000000.0000, CAST(N'2020-08-21' AS Date), CAST(N'2020-08-26' AS Date), 7, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (7, 25, 1, N'VDSNT     ', N'FB        ', CAST(N'2021-02-15' AS Date), 1000000.0000, CAST(N'2021-03-03' AS Date), CAST(N'2021-03-06' AS Date), 2, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (8, 24, 5, N'VDSNT     ', N'FV        ', CAST(N'2020-07-28' AS Date), 1000000.0000, CAST(N'2020-08-15' AS Date), CAST(N'2020-08-19' AS Date), 6, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (9, 20, 7, N'VHFPQ     ', N'BB        ', CAST(N'2021-03-02' AS Date), 1000000.0000, CAST(N'2021-03-25' AS Date), CAST(N'2021-03-29' AS Date), 3, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (10, 10, 17, N'VHFPQ     ', N'RO        ', CAST(N'2021-06-18' AS Date), 1000000.0000, CAST(N'2021-07-05' AS Date), CAST(N'2021-07-07' AS Date), 5, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (11, 15, 9, N'VHH       ', N'BB        ', CAST(N'2020-09-17' AS Date), 1000000.0000, CAST(N'2020-10-16' AS Date), CAST(N'2020-10-17' AS Date), 8, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (12, 12, 4, N'VHRHP     ', N'BB        ', CAST(N'2020-10-19' AS Date), 1000000.0000, CAST(N'2020-11-24' AS Date), CAST(N'2020-11-26' AS Date), 6, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (14, 5, 16, N'VLL81     ', N'HB        ', CAST(N'2021-01-17' AS Date), 1000000.0000, CAST(N'2021-02-21' AS Date), CAST(N'2021-02-23' AS Date), 8, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (15, 2, 13, N'VLNT      ', N'BB        ', CAST(N'2020-05-27' AS Date), 1000000.0000, CAST(N'2020-07-02' AS Date), CAST(N'2020-07-06' AS Date), 3, 0, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (16, 19, 11, N'VLNT      ', N'BV        ', CAST(N'2020-11-29' AS Date), 1000000.0000, CAST(N'2020-12-22' AS Date), CAST(N'2020-12-24' AS Date), 5, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (17, 24, 1, N'VOPQ      ', N'BB        ', CAST(N'2020-09-16' AS Date), 1000000.0000, CAST(N'2020-10-28' AS Date), CAST(N'2020-11-01' AS Date), 8, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (18, 1, 1, N'VOPQ      ', N'BX        ', CAST(N'2020-11-20' AS Date), 1000000.0000, CAST(N'2020-12-10' AS Date), CAST(N'2020-12-13' AS Date), 6, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (19, 20, 8, N'VOPQ      ', N'FX        ', CAST(N'2020-07-31' AS Date), 1000000.0000, CAST(N'2020-09-02' AS Date), CAST(N'2020-09-03' AS Date), 6, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (20, 1, 4, N'VRGNHA    ', N'BB        ', CAST(N'2020-08-26' AS Date), 1000000.0000, CAST(N'2020-10-09' AS Date), CAST(N'2020-10-13' AS Date), 2, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (22, 13, 14, N'VRGPQ     ', N'BX        ', CAST(N'2021-01-08' AS Date), 1000000.0000, CAST(N'2021-01-29' AS Date), CAST(N'2021-02-03' AS Date), 7, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (23, 25, 18, N'VRGPQ     ', N'FB        ', CAST(N'2020-11-23' AS Date), 1000000.0000, CAST(N'2020-12-16' AS Date), CAST(N'2020-12-21' AS Date), 4, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (24, 17, 9, N'VRGPQ     ', N'FX        ', CAST(N'2021-06-10' AS Date), 1000000.0000, CAST(N'2021-07-12' AS Date), CAST(N'2021-07-15' AS Date), 7, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (25, 24, 1, N'VRSNTB    ', N'BB        ', CAST(N'2020-11-10' AS Date), 1000000.0000, CAST(N'2020-12-19' AS Date), CAST(N'2020-12-24' AS Date), 4, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (26, 5, 11, N'VRSNTB    ', N'BV        ', CAST(N'2021-06-06' AS Date), 1000000.0000, CAST(N'2021-06-27' AS Date), CAST(N'2021-06-29' AS Date), 3, 0, N'HCD       ')
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (27, 7, 16, N'VRSPQ     ', N'BX        ', CAST(N'2020-12-25' AS Date), 1000000.0000, CAST(N'2021-01-11' AS Date), CAST(N'2021-01-15' AS Date), 6, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (28, 13, 11, N'VRSPQ     ', N'FB        ', CAST(N'2020-09-12' AS Date), 1000000.0000, CAST(N'2020-10-14' AS Date), CAST(N'2020-10-15' AS Date), 2, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (29, 21, 19, N'VRSPQ     ', N'FX        ', CAST(N'2020-12-06' AS Date), 1000000.0000, CAST(N'2021-01-16' AS Date), CAST(N'2021-01-20' AS Date), 3, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (30, 14, 18, N'VDGPQ     ', N'BB        ', CAST(N'2020-08-12' AS Date), 1000000.0000, CAST(N'2020-08-29' AS Date), CAST(N'2020-09-02' AS Date), 6, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (31, 12, 21, N'VDGPQ     ', N'FB        ', CAST(N'2021-01-02' AS Date), 1000000.0000, CAST(N'2021-02-08' AS Date), CAST(N'2021-02-09' AS Date), 2, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (32, 10, 18, N'VDGPQ     ', N'FX        ', CAST(N'2021-02-01' AS Date), 1000000.0000, CAST(N'2021-03-04' AS Date), CAST(N'2021-03-09' AS Date), 2, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (33, 8, 10, N'VDSNT     ', N'BB        ', CAST(N'2020-10-29' AS Date), 1000000.0000, CAST(N'2020-11-17' AS Date), CAST(N'2020-11-19' AS Date), 8, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (34, 13, 6, N'VDSNT     ', N'BV        ', CAST(N'2021-01-30' AS Date), 1000000.0000, CAST(N'2021-03-05' AS Date), CAST(N'2021-03-06' AS Date), 3, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (35, 4, 12, N'VDSNT     ', N'FV        ', CAST(N'2020-08-01' AS Date), 1000000.0000, CAST(N'2020-09-15' AS Date), CAST(N'2020-09-20' AS Date), 5, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (36, 15, 19, N'VLNT      ', N'BB        ', CAST(N'2021-01-11' AS Date), 1000000.0000, CAST(N'2021-01-28' AS Date), CAST(N'2021-01-29' AS Date), 5, 0, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (38, 5, 14, N'VOPQ      ', N'BB        ', CAST(N'2020-06-20' AS Date), 1000000.0000, CAST(N'2020-07-07' AS Date), CAST(N'2020-07-10' AS Date), 5, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (39, 25, 14, N'VOPQ      ', N'BX        ', CAST(N'2020-08-25' AS Date), 1000000.0000, CAST(N'2020-09-19' AS Date), CAST(N'2020-09-21' AS Date), 3, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (40, 9, 10, N'VRGNHA    ', N'FV        ', CAST(N'2020-05-04' AS Date), 1000000.0000, CAST(N'2020-06-11' AS Date), CAST(N'2020-06-16' AS Date), 7, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (41, 11, 1, N'VRGPQ     ', N'BB        ', CAST(N'2021-02-12' AS Date), 1000000.0000, CAST(N'2021-03-17' AS Date), CAST(N'2021-03-22' AS Date), 6, 0, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (42, 7, 11, N'VRGPQ     ', N'FX        ', CAST(N'2020-06-21' AS Date), 1000000.0000, CAST(N'2020-07-22' AS Date), CAST(N'2020-07-23' AS Date), 3, 0, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (43, 7, 6, N'VRSNTB    ', N'BB        ', CAST(N'2021-03-05' AS Date), 1000000.0000, CAST(N'2021-03-27' AS Date), CAST(N'2021-03-28' AS Date), 6, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (44, 24, 13, N'VRSNTB    ', N'BV        ', CAST(N'2021-01-28' AS Date), 1000000.0000, CAST(N'2021-02-19' AS Date), CAST(N'2021-02-22' AS Date), 7, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (45, 3, 2, N'VDGPQ     ', N'FX        ', CAST(N'2020-12-02' AS Date), 1000000.0000, CAST(N'2020-12-19' AS Date), CAST(N'2020-12-23' AS Date), 7, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (46, 12, 20, N'VDSNT     ', N'BB        ', CAST(N'2021-03-19' AS Date), 1000000.0000, CAST(N'2021-05-03' AS Date), CAST(N'2021-05-05' AS Date), 7, 2, N'HCDDS     ')
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (47, 5, 19, N'VCRDN     ', N'BV        ', CAST(N'2021-06-14' AS Date), 1000000.0000, CAST(N'2021-07-28' AS Date), CAST(N'2021-07-31' AS Date), 5, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (48, 23, 17, N'VLNT      ', N'BV        ', CAST(N'2021-06-04' AS Date), 1000000.0000, CAST(N'2021-07-07' AS Date), CAST(N'2021-07-11' AS Date), 7, 1, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (49, 23, 4, N'VRGPQ     ', N'FB        ', CAST(N'2021-06-24' AS Date), 1000000.0000, CAST(N'2021-07-28' AS Date), CAST(N'2021-07-31' AS Date), 4, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (50, 14, 11, N'VRGNHA    ', N'BB        ', CAST(N'2021-06-13' AS Date), 1000000.0000, CAST(N'2021-07-07' AS Date), CAST(N'2021-07-09' AS Date), 5, 3, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (51, 21, 2, N'VDSNT     ', N'BV        ', CAST(N'2021-06-28' AS Date), 1000000.0000, CAST(N'2021-07-14' AS Date), CAST(N'2021-07-16' AS Date), 4, 2, NULL)
INSERT [dbo].[PHIEUDANGKY] ([MaPDK], [MaKH], [MaNV], [MaKND], [MaGND], [ThoiGian], [TienDat], [NgayDen], [NgayDi], [SoNguoiLon], [SoTreEm], [MaKM]) VALUES (52, 16, 3, N'VLNT      ', N'BV        ', CAST(N'2021-06-14' AS Date), 1000000.0000, CAST(N'2021-07-11' AS Date), CAST(N'2021-07-15' AS Date), 6, 2, NULL)
SET IDENTITY_INSERT [dbo].[PHIEUDANGKY] OFF
GO
SET IDENTITY_INSERT [dbo].[PHIEUHUYPHONG] ON 

INSERT [dbo].[PHIEUHUYPHONG] ([MaPHP], [MaKND], [MaKH], [MaNV], [PhiHP], [ThoiGian]) VALUES (1, N'VDSNT     ', 23, 21, 6384000.0000, CAST(N'2021-04-08' AS Date))
INSERT [dbo].[PHIEUHUYPHONG] ([MaPHP], [MaKND], [MaKH], [MaNV], [PhiHP], [ThoiGian]) VALUES (2, N'VLL81     ', 10, 6, 0.0000, CAST(N'2020-07-01' AS Date))
INSERT [dbo].[PHIEUHUYPHONG] ([MaPHP], [MaKND], [MaKH], [MaNV], [PhiHP], [ThoiGian]) VALUES (3, N'VRGNHA    ', 13, 15, 9834000.0000, CAST(N'2021-01-21' AS Date))
INSERT [dbo].[PHIEUHUYPHONG] ([MaPHP], [MaKND], [MaKH], [MaNV], [PhiHP], [ThoiGian]) VALUES (4, N'VLNT      ', 2, 9, 14702500.0000, CAST(N'2020-10-11' AS Date))
SET IDENTITY_INSERT [dbo].[PHIEUHUYPHONG] OFF
GO
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN01   ', N'VCRDN     ', N'ESK       ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN02   ', N'VCRDN     ', N'ESKRV     ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN03   ', N'VCRDN     ', N'SK        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN04   ', N'VCRDN     ', N'ST        ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN05   ', N'VCRDN     ', N'ESK       ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN06   ', N'VCRDN     ', N'ESKRV     ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN07   ', N'VCRDN     ', N'SK        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN08   ', N'VCRDN     ', N'ST        ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN09   ', N'VCRDN     ', N'ESK       ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN10   ', N'VCRDN     ', N'ESKRV     ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN11   ', N'VCRDN     ', N'SK        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN12   ', N'VCRDN     ', N'ST        ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN13   ', N'VCRDN     ', N'ESK       ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN14   ', N'VCRDN     ', N'ESKRV     ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN15   ', N'VCRDN     ', N'SK        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN16   ', N'VCRDN     ', N'ST        ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN17   ', N'VCRDN     ', N'ESK       ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN18   ', N'VCRDN     ', N'ESKRV     ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN19   ', N'VCRDN     ', N'SK        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN20   ', N'VCRDN     ', N'ST        ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN21   ', N'VCRDN     ', N'ESK       ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN22   ', N'VCRDN     ', N'ESKRV     ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN23   ', N'VCRDN     ', N'SK        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN24   ', N'VCRDN     ', N'ST        ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN25   ', N'VCRDN     ', N'ESK       ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN26   ', N'VCRDN     ', N'ESKRV     ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN27   ', N'VCRDN     ', N'SK        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN28   ', N'VCRDN     ', N'ST        ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN29   ', N'VCRDN     ', N'ESK       ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VCRDN30   ', N'VCRDN     ', N'ESKRV     ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP01    ', N'VDGPQ     ', N'V2B       ', N'V01       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP02    ', N'VDGPQ     ', N'V3B       ', N'V02       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP03    ', N'VDGPQ     ', N'V4B       ', N'V03       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP04    ', N'VDGPQ     ', N'V2B       ', N'V04       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP05    ', N'VDGPQ     ', N'V3B       ', N'V05       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP06    ', N'VDGPQ     ', N'V4B       ', N'V06       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP07    ', N'VDGPQ     ', N'V2B       ', N'V07       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP08    ', N'VDGPQ     ', N'V3B       ', N'V08       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP09    ', N'VDGPQ     ', N'V4B       ', N'V09       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP10    ', N'VDGPQ     ', N'V2B       ', N'V10       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP11    ', N'VDGPQ     ', N'V3B       ', N'V11       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP12    ', N'VDGPQ     ', N'V4B       ', N'V12       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP13    ', N'VDGPQ     ', N'V2B       ', N'V13       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP14    ', N'VDGPQ     ', N'V3B       ', N'V14       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP15    ', N'VDGPQ     ', N'V4B       ', N'V15       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP16    ', N'VDGPQ     ', N'V2B       ', N'V16       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP17    ', N'VDGPQ     ', N'V3B       ', N'V17       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP18    ', N'VDGPQ     ', N'V4B       ', N'V18       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP19    ', N'VDGPQ     ', N'V2B       ', N'V19       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDGP20    ', N'VDGPQ     ', N'V3B       ', N'V20       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT01   ', N'VDSNT     ', N'V2BPV     ', N'V01       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT02   ', N'VDSNT     ', N'V3BB      ', N'V02       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT03   ', N'VDSNT     ', N'V3BPV     ', N'V03       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT04   ', N'VDSNT     ', N'V2BPV     ', N'V04       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT05   ', N'VDSNT     ', N'V3BB      ', N'V05       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT06   ', N'VDSNT     ', N'V3BPV     ', N'V06       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT07   ', N'VDSNT     ', N'V2BPV     ', N'V07       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT08   ', N'VDSNT     ', N'V3BB      ', N'V08       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT09   ', N'VDSNT     ', N'V3BPV     ', N'V09       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT10   ', N'VDSNT     ', N'V2BPV     ', N'V10       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT11   ', N'VDSNT     ', N'V3BB      ', N'V11       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT12   ', N'VDSNT     ', N'V3BPV     ', N'V12       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT13   ', N'VDSNT     ', N'V2BPV     ', N'V13       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT14   ', N'VDSNT     ', N'V3BB      ', N'V14       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT15   ', N'VDSNT     ', N'V3BPV     ', N'V15       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT16   ', N'VDSNT     ', N'V2BPV     ', N'V16       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT17   ', N'VDSNT     ', N'V3BB      ', N'V17       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT18   ', N'VDSNT     ', N'V3BPV     ', N'V18       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT19   ', N'VDSNT     ', N'V2BPV     ', N'V19       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT20   ', N'VDSNT     ', N'V3BB      ', N'V20       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT21   ', N'VDSNT     ', N'V3BPV     ', N'V21       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT22   ', N'VDSNT     ', N'V2BPV     ', N'V22       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT23   ', N'VDSNT     ', N'V3BB      ', N'V23       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VDSNT24   ', N'VDSNT     ', N'V3BPV     ', N'V24       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ01   ', N'VHFPQ     ', N'SK        ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ02   ', N'VHFPQ     ', N'SS        ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ03   ', N'VHFPQ     ', N'ST        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ04   ', N'VHFPQ     ', N'SK        ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ05   ', N'VHFPQ     ', N'SS        ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ06   ', N'VHFPQ     ', N'ST        ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ07   ', N'VHFPQ     ', N'SK        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ08   ', N'VHFPQ     ', N'SS        ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ09   ', N'VHFPQ     ', N'ST        ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ10   ', N'VHFPQ     ', N'SK        ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ11   ', N'VHFPQ     ', N'SS        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ12   ', N'VHFPQ     ', N'ST        ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ13   ', N'VHFPQ     ', N'SK        ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ14   ', N'VHFPQ     ', N'SS        ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ15   ', N'VHFPQ     ', N'ST        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ16   ', N'VHFPQ     ', N'SK        ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ17   ', N'VHFPQ     ', N'SS        ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ18   ', N'VHFPQ     ', N'ST        ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ19   ', N'VHFPQ     ', N'SK        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ20   ', N'VHFPQ     ', N'SS        ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ21   ', N'VHFPQ     ', N'ST        ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ22   ', N'VHFPQ     ', N'SK        ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ23   ', N'VHFPQ     ', N'SS        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ24   ', N'VHFPQ     ', N'ST        ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ25   ', N'VHFPQ     ', N'SK        ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ26   ', N'VHFPQ     ', N'SS        ', N'406       ', 0)
GO
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ27   ', N'VHFPQ     ', N'ST        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ28   ', N'VHFPQ     ', N'SK        ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ29   ', N'VHFPQ     ', N'SS        ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHFPQ30   ', N'VHFPQ     ', N'ST        ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH01     ', N'VHH       ', N'DK        ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH02     ', N'VHH       ', N'DT        ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH03     ', N'VHH       ', N'DK        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH04     ', N'VHH       ', N'DT        ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH05     ', N'VHH       ', N'DK        ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH06     ', N'VHH       ', N'DT        ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH07     ', N'VHH       ', N'DK        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH08     ', N'VHH       ', N'DT        ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH09     ', N'VHH       ', N'DK        ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH10     ', N'VHH       ', N'DT        ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH11     ', N'VHH       ', N'DK        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH12     ', N'VHH       ', N'DT        ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH13     ', N'VHH       ', N'DK        ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH14     ', N'VHH       ', N'DT        ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH15     ', N'VHH       ', N'DK        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH16     ', N'VHH       ', N'DT        ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH17     ', N'VHH       ', N'DK        ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH18     ', N'VHH       ', N'DT        ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH19     ', N'VHH       ', N'DK        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHH20     ', N'VHH       ', N'DT        ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP01   ', N'VHRHP     ', N'BKPV      ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP02   ', N'VHRHP     ', N'BTPV      ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP03   ', N'VHRHP     ', N'DK        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP04   ', N'VHRHP     ', N'DT        ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP05   ', N'VHRHP     ', N'BKPV      ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP06   ', N'VHRHP     ', N'BTPV      ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP07   ', N'VHRHP     ', N'DK        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP08   ', N'VHRHP     ', N'DT        ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP09   ', N'VHRHP     ', N'BKPV      ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP10   ', N'VHRHP     ', N'BTPV      ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP11   ', N'VHRHP     ', N'DK        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP12   ', N'VHRHP     ', N'DT        ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP13   ', N'VHRHP     ', N'BKPV      ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP14   ', N'VHRHP     ', N'BTPV      ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP15   ', N'VHRHP     ', N'DK        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP16   ', N'VHRHP     ', N'DT        ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP17   ', N'VHRHP     ', N'BKPV      ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP18   ', N'VHRHP     ', N'BTPV      ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP19   ', N'VHRHP     ', N'DK        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP20   ', N'VHRHP     ', N'DT        ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP21   ', N'VHRHP     ', N'BKPV      ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP22   ', N'VHRHP     ', N'BTPV      ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP23   ', N'VHRHP     ', N'DK        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP24   ', N'VHRHP     ', N'DT        ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP25   ', N'VHRHP     ', N'BKPV      ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP26   ', N'VHRHP     ', N'BTPV      ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP27   ', N'VHRHP     ', N'DK        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP28   ', N'VHRHP     ', N'DT        ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP29   ', N'VHRHP     ', N'BKPV      ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP30   ', N'VHRHP     ', N'BTPV      ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP31   ', N'VHRHP     ', N'DK        ', N'501       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP32   ', N'VHRHP     ', N'DT        ', N'502       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP33   ', N'VHRHP     ', N'BKPV      ', N'503       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP34   ', N'VHRHP     ', N'BTPV      ', N'504       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP35   ', N'VHRHP     ', N'DK        ', N'505       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP36   ', N'VHRHP     ', N'DT        ', N'506       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP37   ', N'VHRHP     ', N'BKPV      ', N'507       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP38   ', N'VHRHP     ', N'BTPV      ', N'508       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP39   ', N'VHRHP     ', N'DK        ', N'509       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VHRHP40   ', N'VHRHP     ', N'DT        ', N'510       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8101   ', N'VLL81     ', N'CK        ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8102   ', N'VLL81     ', N'CT        ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8103   ', N'VLL81     ', N'PK        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8104   ', N'VLL81     ', N'PT        ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8105   ', N'VLL81     ', N'CK        ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8106   ', N'VLL81     ', N'CT        ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8107   ', N'VLL81     ', N'PK        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8108   ', N'VLL81     ', N'PT        ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8109   ', N'VLL81     ', N'CK        ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8110   ', N'VLL81     ', N'CT        ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8111   ', N'VLL81     ', N'PK        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8112   ', N'VLL81     ', N'PT        ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8113   ', N'VLL81     ', N'CK        ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8114   ', N'VLL81     ', N'CT        ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8115   ', N'VLL81     ', N'PK        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8116   ', N'VLL81     ', N'PT        ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8117   ', N'VLL81     ', N'CK        ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8118   ', N'VLL81     ', N'CT        ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8119   ', N'VLL81     ', N'PK        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8120   ', N'VLL81     ', N'PT        ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8121   ', N'VLL81     ', N'CK        ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8122   ', N'VLL81     ', N'CT        ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8123   ', N'VLL81     ', N'PK        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8124   ', N'VLL81     ', N'PT        ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8125   ', N'VLL81     ', N'CK        ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8126   ', N'VLL81     ', N'CT        ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8127   ', N'VLL81     ', N'PK        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8128   ', N'VLL81     ', N'PT        ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8129   ', N'VLL81     ', N'CK        ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLL8130   ', N'VLL81     ', N'CT        ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT01    ', N'VLNT      ', N'PHTB      ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT02    ', N'VLNT      ', N'PHTG      ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT03    ', N'VLNT      ', N'PHTP      ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT04    ', N'VLNT      ', N'PKB       ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT05    ', N'VLNT      ', N'PKG       ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT06    ', N'VLNT      ', N'PKP       ', N'206       ', 0)
GO
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT07    ', N'VLNT      ', N'PHTB      ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT08    ', N'VLNT      ', N'PHTG      ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT09    ', N'VLNT      ', N'PHTP      ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT10    ', N'VLNT      ', N'PKB       ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT11    ', N'VLNT      ', N'PKG       ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT12    ', N'VLNT      ', N'PKP       ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT13    ', N'VLNT      ', N'PHTB      ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT14    ', N'VLNT      ', N'PHTG      ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT15    ', N'VLNT      ', N'PHTP      ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT16    ', N'VLNT      ', N'PKB       ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT17    ', N'VLNT      ', N'PKG       ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT18    ', N'VLNT      ', N'PKP       ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT19    ', N'VLNT      ', N'PHTB      ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT20    ', N'VLNT      ', N'PHTG      ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT21    ', N'VLNT      ', N'PHTP      ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT22    ', N'VLNT      ', N'PKB       ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT23    ', N'VLNT      ', N'PKG       ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT24    ', N'VLNT      ', N'PKP       ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT25    ', N'VLNT      ', N'PHTB      ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT26    ', N'VLNT      ', N'PHTG      ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT27    ', N'VLNT      ', N'PHTP      ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT28    ', N'VLNT      ', N'PKB       ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT29    ', N'VLNT      ', N'PKG       ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT30    ', N'VLNT      ', N'PKP       ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT31    ', N'VLNT      ', N'PHTB      ', N'501       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT32    ', N'VLNT      ', N'PHTG      ', N'502       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT33    ', N'VLNT      ', N'PHTP      ', N'503       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT34    ', N'VLNT      ', N'PKB       ', N'504       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT35    ', N'VLNT      ', N'PKG       ', N'505       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT36    ', N'VLNT      ', N'PKP       ', N'506       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT37    ', N'VLNT      ', N'PHTB      ', N'507       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT38    ', N'VLNT      ', N'PHTG      ', N'508       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT39    ', N'VLNT      ', N'PHTP      ', N'509       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VLNT40    ', N'VLNT      ', N'PKB       ', N'510       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ01    ', N'VOPQ      ', N'JS        ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ02    ', N'VOPQ      ', N'SK        ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ03    ', N'VOPQ      ', N'ST        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ04    ', N'VOPQ      ', N'JS        ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ05    ', N'VOPQ      ', N'SK        ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ06    ', N'VOPQ      ', N'ST        ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ07    ', N'VOPQ      ', N'JS        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ08    ', N'VOPQ      ', N'SK        ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ09    ', N'VOPQ      ', N'ST        ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ10    ', N'VOPQ      ', N'JS        ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ11    ', N'VOPQ      ', N'SK        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ12    ', N'VOPQ      ', N'ST        ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ13    ', N'VOPQ      ', N'JS        ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ14    ', N'VOPQ      ', N'SK        ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ15    ', N'VOPQ      ', N'ST        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ16    ', N'VOPQ      ', N'JS        ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ17    ', N'VOPQ      ', N'SK        ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ18    ', N'VOPQ      ', N'ST        ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ19    ', N'VOPQ      ', N'JS        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ20    ', N'VOPQ      ', N'SK        ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ21    ', N'VOPQ      ', N'ST        ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ22    ', N'VOPQ      ', N'JS        ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ23    ', N'VOPQ      ', N'SK        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ24    ', N'VOPQ      ', N'ST        ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ25    ', N'VOPQ      ', N'JS        ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ26    ', N'VOPQ      ', N'SK        ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ27    ', N'VOPQ      ', N'ST        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ28    ', N'VOPQ      ', N'JS        ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ29    ', N'VOPQ      ', N'SK        ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VOPQ30    ', N'VOPQ      ', N'ST        ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA01  ', N'VRGNHA    ', N'DK        ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA02  ', N'VRGNHA    ', N'DKOV      ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA03  ', N'VRGNHA    ', N'DT        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA04  ', N'VRGNHA    ', N'DTOV      ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA05  ', N'VRGNHA    ', N'DK        ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA06  ', N'VRGNHA    ', N'DKOV      ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA07  ', N'VRGNHA    ', N'DT        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA08  ', N'VRGNHA    ', N'DTOV      ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA09  ', N'VRGNHA    ', N'DK        ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA10  ', N'VRGNHA    ', N'DKOV      ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA11  ', N'VRGNHA    ', N'DT        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA12  ', N'VRGNHA    ', N'DTOV      ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA13  ', N'VRGNHA    ', N'DK        ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA14  ', N'VRGNHA    ', N'DKOV      ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA15  ', N'VRGNHA    ', N'DT        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA16  ', N'VRGNHA    ', N'DTOV      ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA17  ', N'VRGNHA    ', N'DK        ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA18  ', N'VRGNHA    ', N'DKOV      ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA19  ', N'VRGNHA    ', N'DT        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA20  ', N'VRGNHA    ', N'DTOV      ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA21  ', N'VRGNHA    ', N'DK        ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA22  ', N'VRGNHA    ', N'DKOV      ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA23  ', N'VRGNHA    ', N'DT        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA24  ', N'VRGNHA    ', N'DTOV      ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA25  ', N'VRGNHA    ', N'DK        ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA26  ', N'VRGNHA    ', N'DKOV      ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA27  ', N'VRGNHA    ', N'DT        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA28  ', N'VRGNHA    ', N'DTOV      ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA29  ', N'VRGNHA    ', N'DK        ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA30  ', N'VRGNHA    ', N'DKOV      ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA31  ', N'VRGNHA    ', N'V3B       ', N'V01       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA32  ', N'VRGNHA    ', N'V3B       ', N'V02       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA33  ', N'VRGNHA    ', N'V3B       ', N'V03       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA34  ', N'VRGNHA    ', N'V3B       ', N'V04       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGNHA35  ', N'VRGNHA    ', N'V3B       ', N'V05       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ01   ', N'VRGPQ     ', N'DK        ', N'201       ', 0)
GO
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ02   ', N'VRGPQ     ', N'DKOV      ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ03   ', N'VRGPQ     ', N'DT        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ04   ', N'VRGPQ     ', N'DTOV      ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ05   ', N'VRGPQ     ', N'DK        ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ06   ', N'VRGPQ     ', N'DKOV      ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ07   ', N'VRGPQ     ', N'DT        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ08   ', N'VRGPQ     ', N'DTOV      ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ09   ', N'VRGPQ     ', N'DK        ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ10   ', N'VRGPQ     ', N'DKOV      ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ11   ', N'VRGPQ     ', N'DT        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ12   ', N'VRGPQ     ', N'DTOV      ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ13   ', N'VRGPQ     ', N'DK        ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ14   ', N'VRGPQ     ', N'DKOV      ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ15   ', N'VRGPQ     ', N'DT        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ16   ', N'VRGPQ     ', N'DTOV      ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ17   ', N'VRGPQ     ', N'DK        ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ18   ', N'VRGPQ     ', N'DKOV      ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ19   ', N'VRGPQ     ', N'DT        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ20   ', N'VRGPQ     ', N'DTOV      ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ21   ', N'VRGPQ     ', N'DK        ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ22   ', N'VRGPQ     ', N'DKOV      ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ23   ', N'VRGPQ     ', N'DT        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ24   ', N'VRGPQ     ', N'DTOV      ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ25   ', N'VRGPQ     ', N'DK        ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ26   ', N'VRGPQ     ', N'DKOV      ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ27   ', N'VRGPQ     ', N'DT        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ28   ', N'VRGPQ     ', N'DTOV      ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ29   ', N'VRGPQ     ', N'DK        ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ30   ', N'VRGPQ     ', N'DKOV      ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ31   ', N'VRGPQ     ', N'DT        ', N'501       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ32   ', N'VRGPQ     ', N'DTOV      ', N'502       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ33   ', N'VRGPQ     ', N'DK        ', N'503       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ34   ', N'VRGPQ     ', N'DKOV      ', N'504       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ35   ', N'VRGPQ     ', N'DT        ', N'505       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ36   ', N'VRGPQ     ', N'V2B       ', N'V01       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ37   ', N'VRGPQ     ', N'V3B       ', N'V02       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ38   ', N'VRGPQ     ', N'V4B       ', N'V03       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ39   ', N'VRGPQ     ', N'V2B       ', N'V04       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ40   ', N'VRGPQ     ', N'V3B       ', N'V05       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ41   ', N'VRGPQ     ', N'V4B       ', N'V06       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ42   ', N'VRGPQ     ', N'V2B       ', N'V07       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ43   ', N'VRGPQ     ', N'V3B       ', N'V08       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ44   ', N'VRGPQ     ', N'V4B       ', N'V09       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ45   ', N'VRGPQ     ', N'V2B       ', N'V10       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ46   ', N'VRGPQ     ', N'V3B       ', N'V11       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRGPQ47   ', N'VRGPQ     ', N'V4B       ', N'V12       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB01  ', N'VRSNTB    ', N'DK        ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB02  ', N'VRSNTB    ', N'DKOV      ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB03  ', N'VRSNTB    ', N'DT        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB04  ', N'VRSNTB    ', N'DTOV      ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB05  ', N'VRSNTB    ', N'DK        ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB06  ', N'VRSNTB    ', N'DKOV      ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB07  ', N'VRSNTB    ', N'DT        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB08  ', N'VRSNTB    ', N'DTOV      ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB09  ', N'VRSNTB    ', N'DK        ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB10  ', N'VRSNTB    ', N'DKOV      ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB11  ', N'VRSNTB    ', N'DT        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB12  ', N'VRSNTB    ', N'DTOV      ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB13  ', N'VRSNTB    ', N'DK        ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB14  ', N'VRSNTB    ', N'DKOV      ', N'304       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB15  ', N'VRSNTB    ', N'DT        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB16  ', N'VRSNTB    ', N'DTOV      ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB17  ', N'VRSNTB    ', N'DK        ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB18  ', N'VRSNTB    ', N'DKOV      ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB19  ', N'VRSNTB    ', N'DT        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB20  ', N'VRSNTB    ', N'DTOV      ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB21  ', N'VRSNTB    ', N'DK        ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB22  ', N'VRSNTB    ', N'DKOV      ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB23  ', N'VRSNTB    ', N'DT        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB24  ', N'VRSNTB    ', N'DTOV      ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB25  ', N'VRSNTB    ', N'DK        ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB26  ', N'VRSNTB    ', N'DKOV      ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB27  ', N'VRSNTB    ', N'DT        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB28  ', N'VRSNTB    ', N'DTOV      ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB29  ', N'VRSNTB    ', N'DK        ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB30  ', N'VRSNTB    ', N'DKOV      ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB31  ', N'VRSNTB    ', N'V2BPV     ', N'V01       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB32  ', N'VRSNTB    ', N'V3BPV     ', N'V02       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB33  ', N'VRSNTB    ', N'V2BPV     ', N'V03       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB34  ', N'VRSNTB    ', N'V3BPV     ', N'V04       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB35  ', N'VRSNTB    ', N'V2BPV     ', N'V05       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB36  ', N'VRSNTB    ', N'V3BPV     ', N'V06       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB37  ', N'VRSNTB    ', N'V2BPV     ', N'V07       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB38  ', N'VRSNTB    ', N'V3BPV     ', N'V08       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB39  ', N'VRSNTB    ', N'V2BPV     ', N'V09       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSNTB40  ', N'VRSNTB    ', N'V3BPV     ', N'V10       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ01   ', N'VRSPQ     ', N'DK        ', N'201       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ02   ', N'VRSPQ     ', N'DKOV      ', N'202       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ03   ', N'VRSPQ     ', N'DT        ', N'203       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ04   ', N'VRSPQ     ', N'DTOV      ', N'204       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ05   ', N'VRSPQ     ', N'DK        ', N'205       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ06   ', N'VRSPQ     ', N'DKOV      ', N'206       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ07   ', N'VRSPQ     ', N'DT        ', N'207       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ08   ', N'VRSPQ     ', N'DTOV      ', N'208       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ09   ', N'VRSPQ     ', N'DK        ', N'209       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ10   ', N'VRSPQ     ', N'DKOV      ', N'210       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ11   ', N'VRSPQ     ', N'DT        ', N'301       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ12   ', N'VRSPQ     ', N'DTOV      ', N'302       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ13   ', N'VRSPQ     ', N'DK        ', N'303       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ14   ', N'VRSPQ     ', N'DKOV      ', N'304       ', 0)
GO
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ15   ', N'VRSPQ     ', N'DT        ', N'305       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ16   ', N'VRSPQ     ', N'DTOV      ', N'306       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ17   ', N'VRSPQ     ', N'DK        ', N'307       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ18   ', N'VRSPQ     ', N'DKOV      ', N'308       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ19   ', N'VRSPQ     ', N'DT        ', N'309       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ20   ', N'VRSPQ     ', N'DTOV      ', N'310       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ21   ', N'VRSPQ     ', N'DK        ', N'401       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ22   ', N'VRSPQ     ', N'DKOV      ', N'402       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ23   ', N'VRSPQ     ', N'DT        ', N'403       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ24   ', N'VRSPQ     ', N'DTOV      ', N'404       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ25   ', N'VRSPQ     ', N'DK        ', N'405       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ26   ', N'VRSPQ     ', N'DKOV      ', N'406       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ27   ', N'VRSPQ     ', N'DT        ', N'407       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ28   ', N'VRSPQ     ', N'DTOV      ', N'408       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ29   ', N'VRSPQ     ', N'DK        ', N'409       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ30   ', N'VRSPQ     ', N'DKOV      ', N'410       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ31   ', N'VRSPQ     ', N'V3B       ', N'V01       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ32   ', N'VRSPQ     ', N'V3B       ', N'V02       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ33   ', N'VRSPQ     ', N'V3B       ', N'V03       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ34   ', N'VRSPQ     ', N'V3B       ', N'V04       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ35   ', N'VRSPQ     ', N'V3B       ', N'V05       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ36   ', N'VRSPQ     ', N'V3B       ', N'V06       ', 0)
INSERT [dbo].[PHONG] ([MaP], [MaKND], [MaLP], [SoP], [TrangThai]) VALUES (N'VRSPQ37   ', N'VRSPQ     ', N'V3B       ', N'V07       ', 0)
GO
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (1, N'PHI CHECK-IN SOM', 9382000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (1, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (2, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (4, N'PHI CHECK-OUT MUON', 7364000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (5, N'PHI KE GIUONG PHU TRE EM', 1500000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (5, N'PHI PHU THU NGUOI LON', 4000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (6, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (7, N'PHI KE GIUONG PHU TRE EM', 1500000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (7, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (8, N'PHI CHECK-IN SOM', 3292000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (9, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (10, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (11, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (11, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (12, N'PHI CHECK-IN SOM', 9627000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (12, N'PHI KE GIUONG PHU TRE EM', 1500000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (12, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (13, N'PHI CHECK-OUT MUON', 12416000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (13, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (14, N'PHI CHECK-IN SOM', 10576000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (16, N'PHI CHECK-OUT MUON', 1824500.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (16, N'PHI KE GIUONG PHU TRE EM', 1500000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (17, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (18, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (19, N'PHI KE GIUONG PHU TRE EM', 1500000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (20, N'PHI CHECK-OUT MUON', 3423500.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (20, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (21, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (23, N'PHI PHU THU NGUOI LON', 10000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (23, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (24, N'PHI CHECK-OUT MUON', 7152000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (24, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (25, N'PHI CHECK-IN SOM', 2193632.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (25, N'PHI PHU THU NGUOI LON', 4000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (26, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (26, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (27, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (28, N'PHI CHECK-IN SOM', 7176000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (28, N'PHI CHECK-OUT MUON', 3588000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (28, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (28, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (30, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (31, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (32, N'PHI CHECK-IN SOM', 5912000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (33, N'PHI CHECK-OUT MUON', 12588000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (33, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (33, N'PHI PHU THU TRE EM', 1000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (34, N'PHI CHECK-IN SOM', 3988000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (34, N'PHI PHU THU TRE EM', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (35, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (36, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (37, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (38, N'PHI CHECK-IN SOM', 11800000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (38, N'PHI KE GIUONG PHU TRE EM', 3000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (38, N'PHI PHU THU NGUOI LON', 2000000.0000)
INSERT [dbo].[PHUTHU] ([MaHD], [TenPT], [SoTien]) VALUES (39, N'PHI KE GIUONG PHU TRE EM', 1500000.0000)
GO
ALTER TABLE [dbo].[HOADON] ADD  DEFAULT ('14:00:00') FOR [TGCheck-in]
GO
ALTER TABLE [dbo].[HOADON] ADD  DEFAULT ('12:00:00') FOR [TGCheck-out]
GO
ALTER TABLE [dbo].[HOADON] ADD  DEFAULT ((0)) FOR [SoNguoiLon]
GO
ALTER TABLE [dbo].[HOADON] ADD  DEFAULT ((0)) FOR [SoTreEm]
GO
ALTER TABLE [dbo].[HOADON] ADD  DEFAULT ('Chuy?n Kho?n') FOR [HinhThucTT]
GO
ALTER TABLE [dbo].[LOAIPHONG] ADD  DEFAULT ((0)) FOR [SoTreEm]
GO
ALTER TABLE [dbo].[CCDICHVU]  WITH CHECK ADD  CONSTRAINT [FK_CCDICHVU_DICHVU] FOREIGN KEY([MaDV])
REFERENCES [dbo].[DICHVU] ([MaDV])
GO
ALTER TABLE [dbo].[CCDICHVU] CHECK CONSTRAINT [FK_CCDICHVU_DICHVU]
GO
ALTER TABLE [dbo].[CCDICHVU]  WITH CHECK ADD  CONSTRAINT [FK_CCDICHVU_KHUNGHIDUONG] FOREIGN KEY([MaKND])
REFERENCES [dbo].[KHUNGHIDUONG] ([MaKND])
GO
ALTER TABLE [dbo].[CCDICHVU] CHECK CONSTRAINT [FK_CCDICHVU_KHUNGHIDUONG]
GO
ALTER TABLE [dbo].[CCGOINGHIDUONG]  WITH CHECK ADD  CONSTRAINT [FK_CCGOINGHIDUONG_GOINGHIDUONG] FOREIGN KEY([MaGND])
REFERENCES [dbo].[GOINGHIDUONG] ([MaGND])
GO
ALTER TABLE [dbo].[CCGOINGHIDUONG] CHECK CONSTRAINT [FK_CCGOINGHIDUONG_GOINGHIDUONG]
GO
ALTER TABLE [dbo].[CCGOINGHIDUONG]  WITH CHECK ADD  CONSTRAINT [FK_CCGOINGHIDUONG_KHUNGHIDUONG] FOREIGN KEY([MaKND])
REFERENCES [dbo].[KHUNGHIDUONG] ([MaKND])
GO
ALTER TABLE [dbo].[CCGOINGHIDUONG] CHECK CONSTRAINT [FK_CCGOINGHIDUONG_KHUNGHIDUONG]
GO
ALTER TABLE [dbo].[CCKHUYENMAI]  WITH CHECK ADD  CONSTRAINT [FK_CCKHUYENMAI_KHUNGHIDUONG] FOREIGN KEY([MaKND])
REFERENCES [dbo].[KHUNGHIDUONG] ([MaKND])
GO
ALTER TABLE [dbo].[CCKHUYENMAI] CHECK CONSTRAINT [FK_CCKHUYENMAI_KHUNGHIDUONG]
GO
ALTER TABLE [dbo].[CCKHUYENMAI]  WITH CHECK ADD  CONSTRAINT [FK_CCKHUYENMAI_KHUYENMAI] FOREIGN KEY([MaKM])
REFERENCES [dbo].[KHUYENMAI] ([MaKM])
GO
ALTER TABLE [dbo].[CCKHUYENMAI] CHECK CONSTRAINT [FK_CCKHUYENMAI_KHUYENMAI]
GO
ALTER TABLE [dbo].[CCLOAIPHONG]  WITH CHECK ADD  CONSTRAINT [FK_CCLOAIPHONG_KHUNGHIDUONG] FOREIGN KEY([MaKND])
REFERENCES [dbo].[KHUNGHIDUONG] ([MaKND])
GO
ALTER TABLE [dbo].[CCLOAIPHONG] CHECK CONSTRAINT [FK_CCLOAIPHONG_KHUNGHIDUONG]
GO
ALTER TABLE [dbo].[CCLOAIPHONG]  WITH CHECK ADD  CONSTRAINT [FK_CCLOAIPHONG_LOAIPHONG] FOREIGN KEY([MaLP])
REFERENCES [dbo].[LOAIPHONG] ([MaLP])
GO
ALTER TABLE [dbo].[CCLOAIPHONG] CHECK CONSTRAINT [FK_CCLOAIPHONG_LOAIPHONG]
GO
ALTER TABLE [dbo].[CTHOADON]  WITH CHECK ADD  CONSTRAINT [FK_CTHOADON_HOADON] FOREIGN KEY([MaHD])
REFERENCES [dbo].[HOADON] ([MaHD])
GO
ALTER TABLE [dbo].[CTHOADON] CHECK CONSTRAINT [FK_CTHOADON_HOADON]
GO
ALTER TABLE [dbo].[CTHOADON]  WITH CHECK ADD  CONSTRAINT [FK_CTHOADON_PHONG] FOREIGN KEY([MaP])
REFERENCES [dbo].[PHONG] ([MaP])
GO
ALTER TABLE [dbo].[CTHOADON] CHECK CONSTRAINT [FK_CTHOADON_PHONG]
GO
ALTER TABLE [dbo].[DKLOAIPHONG]  WITH CHECK ADD  CONSTRAINT [FK_DKLOAIPHONG_LOAIPHONG] FOREIGN KEY([MaLP])
REFERENCES [dbo].[LOAIPHONG] ([MaLP])
GO
ALTER TABLE [dbo].[DKLOAIPHONG] CHECK CONSTRAINT [FK_DKLOAIPHONG_LOAIPHONG]
GO
ALTER TABLE [dbo].[DKLOAIPHONG]  WITH CHECK ADD  CONSTRAINT [FK_DKLOAIPHONG_PHIEUDANGKY] FOREIGN KEY([MaPDK])
REFERENCES [dbo].[PHIEUDANGKY] ([MaPDK])
GO
ALTER TABLE [dbo].[DKLOAIPHONG] CHECK CONSTRAINT [FK_DKLOAIPHONG_PHIEUDANGKY]
GO
ALTER TABLE [dbo].[GIAPT]  WITH CHECK ADD  CONSTRAINT [FK_GIAPT_GOINGHIDUONG] FOREIGN KEY([MaGND])
REFERENCES [dbo].[GOINGHIDUONG] ([MaGND])
GO
ALTER TABLE [dbo].[GIAPT] CHECK CONSTRAINT [FK_GIAPT_GOINGHIDUONG]
GO
ALTER TABLE [dbo].[GIAPT]  WITH CHECK ADD  CONSTRAINT [FK_GIAPT_KHUNGHIDUONG] FOREIGN KEY([MaKND])
REFERENCES [dbo].[KHUNGHIDUONG] ([MaKND])
GO
ALTER TABLE [dbo].[GIAPT] CHECK CONSTRAINT [FK_GIAPT_KHUNGHIDUONG]
GO
ALTER TABLE [dbo].[HOADON]  WITH CHECK ADD  CONSTRAINT [FK_HOADON_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[HOADON] CHECK CONSTRAINT [FK_HOADON_NHANVIEN]
GO
ALTER TABLE [dbo].[HOADON]  WITH CHECK ADD  CONSTRAINT [FK_HOADON_PHIEUDANGKY] FOREIGN KEY([MaPDK])
REFERENCES [dbo].[PHIEUDANGKY] ([MaPDK])
GO
ALTER TABLE [dbo].[HOADON] CHECK CONSTRAINT [FK_HOADON_PHIEUDANGKY]
GO
ALTER TABLE [dbo].[PHIEUDANGKY]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUDANGKY_GOINGHIDUONG] FOREIGN KEY([MaGND])
REFERENCES [dbo].[GOINGHIDUONG] ([MaGND])
GO
ALTER TABLE [dbo].[PHIEUDANGKY] CHECK CONSTRAINT [FK_PHIEUDANGKY_GOINGHIDUONG]
GO
ALTER TABLE [dbo].[PHIEUDANGKY]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUDANGKY_KHACHHANG] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KHACHHANG] ([MaKH])
GO
ALTER TABLE [dbo].[PHIEUDANGKY] CHECK CONSTRAINT [FK_PHIEUDANGKY_KHACHHANG]
GO
ALTER TABLE [dbo].[PHIEUDANGKY]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUDANGKY_KHUNGHIDUONG] FOREIGN KEY([MaKND])
REFERENCES [dbo].[KHUNGHIDUONG] ([MaKND])
GO
ALTER TABLE [dbo].[PHIEUDANGKY] CHECK CONSTRAINT [FK_PHIEUDANGKY_KHUNGHIDUONG]
GO
ALTER TABLE [dbo].[PHIEUDANGKY]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUDANGKY_KHUYENMAI] FOREIGN KEY([MaKM])
REFERENCES [dbo].[KHUYENMAI] ([MaKM])
GO
ALTER TABLE [dbo].[PHIEUDANGKY] CHECK CONSTRAINT [FK_PHIEUDANGKY_KHUYENMAI]
GO
ALTER TABLE [dbo].[PHIEUDANGKY]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUDANGKY_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[PHIEUDANGKY] CHECK CONSTRAINT [FK_PHIEUDANGKY_NHANVIEN]
GO
ALTER TABLE [dbo].[PHIEUHUYPHONG]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUHUYPHONG_KHACHHANG] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KHACHHANG] ([MaKH])
GO
ALTER TABLE [dbo].[PHIEUHUYPHONG] CHECK CONSTRAINT [FK_PHIEUHUYPHONG_KHACHHANG]
GO
ALTER TABLE [dbo].[PHIEUHUYPHONG]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUHUYPHONG_KHUNGHIDUONG] FOREIGN KEY([MaKND])
REFERENCES [dbo].[KHUNGHIDUONG] ([MaKND])
GO
ALTER TABLE [dbo].[PHIEUHUYPHONG] CHECK CONSTRAINT [FK_PHIEUHUYPHONG_KHUNGHIDUONG]
GO
ALTER TABLE [dbo].[PHIEUHUYPHONG]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUHUYPHONG_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[PHIEUHUYPHONG] CHECK CONSTRAINT [FK_PHIEUHUYPHONG_NHANVIEN]
GO
ALTER TABLE [dbo].[PHONG]  WITH CHECK ADD  CONSTRAINT [FK_PHONG_KHUNGHIDUONG] FOREIGN KEY([MaKND])
REFERENCES [dbo].[KHUNGHIDUONG] ([MaKND])
GO
ALTER TABLE [dbo].[PHONG] CHECK CONSTRAINT [FK_PHONG_KHUNGHIDUONG]
GO
ALTER TABLE [dbo].[PHONG]  WITH CHECK ADD  CONSTRAINT [FK_PHONG_LOAIPHONG] FOREIGN KEY([MaLP])
REFERENCES [dbo].[LOAIPHONG] ([MaLP])
GO
ALTER TABLE [dbo].[PHONG] CHECK CONSTRAINT [FK_PHONG_LOAIPHONG]
GO
ALTER TABLE [dbo].[PHUTHU]  WITH CHECK ADD  CONSTRAINT [FK_PHUTHU_HOADON] FOREIGN KEY([MaHD])
REFERENCES [dbo].[HOADON] ([MaHD])
GO
ALTER TABLE [dbo].[PHUTHU] CHECK CONSTRAINT [FK_PHUTHU_HOADON]
GO
/****** Object:  StoredProcedure [dbo].[usp_CHITIET_KND]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_CHITIET_KND](
@MaKND NCHAR(10))
AS 
BEGIN
    SELECT TenGND, GiaGND, ChiTiet
    FROM CCGOINGHIDUONG C, GOINGHIDUONG G
	WHERE C.MaGND = G.MaGND AND MaKND = @MaKND;
    SELECT TenDV
    FROM CCDICHVU C, DICHVU D
	WHERE C.MaDV = D.MaDV AND MaKND = @MaKND;
	SELECT TenLP, SoNguoiLon, SoTreEm, GiaLP
    FROM CCLOAIPHONG C, LOAIPHONG L
	WHERE C.MaLP = L.MaLP AND MaKND = @MaKND;
	SELECT TenKM, ChietKhau, DieuKien
    FROM CCKHUYENMAI C, KHUYENMAI K
	WHERE C.MaKM = K.MaKM AND MaKND = @MaKND;
END

GO
/****** Object:  StoredProcedure [dbo].[usp_DTMAX_KND]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[usp_DTMAX_KND](
@NgayBD DATE,
@NgayKT DATE)
AS
BEGIN
    SELECT MaKND, TenKND, dbo.fu_DOANHTHU(MaKND,@NgayBD,@NgayKT) AS DoanhThu
	FROM KHUNGHIDUONG
	ORDER BY DoanhThu DESC
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GND_MAX]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Hiển thị những gói nghỉ dưỡng được chọn nhiều nhất của 1 khu nghỉ dưỡng trong 1 khoảng thời gian*/

Create PROC [dbo].[usp_GND_MAX]
	@MaKND nchar(10),
	@t1 date,
	@t2 date
AS
Begin 
	select TOP 10 P.MaGND, TenGND,
	       count(P.MaGND) AS SoLuotChon
    from PHIEUDANGKY P, GOINGHIDUONG G
	WHERE P.MaKND = @MaKND AND P.MaGND = G.MaGND
	group by P.MaGND, TenGND
	order by count(P.MaGND) desc
end
GO
/****** Object:  StoredProcedure [dbo].[usp_HUYPHONG]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[usp_HUYPHONG](
@MaPDK INT,
@MaNV INT,
@NgayHuy DATE)
AS
BEGIN
    DECLARE @MaKND NCHAR(10),
	        @MaKH INT;
	SET @MaKH = (SELECT MaKH FROM PHIEUDANGKY WHERE MaPDK = @MaPDK);
	SET @MaKND = (SELECT MaKND FROM PHIEUDANGKY WHERE MaPDK = @MaPDK);
    INSERT INTO PHIEUHUYPHONG
	VALUES(@MaKND,@MaKH,@MaNV,dbo.fu_PHIHP(@MaPDK,@NgayHuy),@NgayHuy);
	DELETE FROM DKLOAIPHONG
	WHERE MaPDK = @MaPDK;
	DELETE FROM PHIEUDANGKY
	WHERE MaPDK = @MaPDK;
END
GO
/****** Object:  StoredProcedure [dbo].[usp_KH_DK_MAX]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*Hiển thị những khách hàng đăng ký nhiều nhất trong 1 khoảng thời gian*/

Create PROC [dbo].[usp_KH_DK_MAX]
	@t1 date,
	@t2 date
AS
Begin 
	select top 3 PHIEUDANGKY.MaKH, HoTenKH, count(PHIEUDANGKY.MaPDK) as 'So luot dang ky nghi duong'
	from PHIEUDANGKY, KHACHHANG
	where PHIEUDANGKY.MaKH = KHACHHANG.MaKH and Thoigian BETWEEN @t1 AND @t2
	group by PHIEUDANGKY.MaKH, HoTenKH
	order by count(PHIEUDANGKY.MaPDK) desc
end

GO
/****** Object:  StoredProcedure [dbo].[usp_KH_MONEY_MAX]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [dbo].[usp_KH_MONEY_MAX]
	@t1 date,
	@t2 date
AS
Begin 
	select top 3 PHIEUDANGKY.MaKH, HoTenKH, SUM(TongTien) as 'So tien da chi'
	from PHIEUDANGKY, KHACHHANG, HOADON
	where PHIEUDANGKY.MaKH = KHACHHANG.MaKH AND PHIEUDANGKY.MaPDK = HOADON.MaPDK and PHIEUDANGKY.Thoigian BETWEEN @t1 AND @t2
	group by PHIEUDANGKY.MaKH, HoTenKH
	order by SUM(TongTien) desc
end
GO
/****** Object:  StoredProcedure [dbo].[usp_KND_DK_MAX]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Hiển thị những khu nghỉ dưỡng được đăng ký nhiều nhất trong 1 khoảng thời gian*/

Create PROC [dbo].[usp_KND_DK_MAX]
	@t1 date,
	@t2 date
AS
Begin 
	select top 3 PHIEUDANGKY.MaKND, TenKND, count(PHIEUDANGKY.MaKND) as 'So luot dang ky'
	from PHIEUDANGKY, KHUNGHIDUONG
	where PHIEUDANGKY.MaKND = KHUNGHIDUONG.MaKND and Thoigian BETWEEN @t1 AND @t2
	group by PHIEUDANGKY.MaKND, TenKND 
	order by count(PHIEUDANGKY.MaKND) desc
end
GO
/****** Object:  StoredProcedure [dbo].[usp_KND_DK_MIN]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [dbo].[usp_KND_DK_MIN]
	@t1 date,
	@t2 date
AS
Begin 
	select top 3 PHIEUDANGKY.MaKND, TenKND, count(PHIEUDANGKY.MaKND) as 'So luot dang ky'
	from PHIEUDANGKY, KHUNGHIDUONG
	where PHIEUDANGKY.MaKND = KHUNGHIDUONG.MaKND and Thoigian BETWEEN @t1 AND @t2
	group by PHIEUDANGKY.MaKND, TenKND 
	order by count(PHIEUDANGKY.MaKND)
end
GO
/****** Object:  StoredProcedure [dbo].[usp_KND_KH_MAX]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Hiển thị những khu nghỉ dưỡng có nhiều khách hàng nhất trong 1 khoảng thơi gian*/

Create PROC [dbo].[usp_KND_KH_MAX]
	@t1 date,
	@t2 date
AS
Begin 
	select top 3 PHIEUDANGKY.MaKND, TenKND, SUM(SoNguoiLon) + SUM(SoTreEm) as 'So khach hang'
	from PHIEUDANGKY, KHUNGHIDUONG
	where PHIEUDANGKY.MaKND = KHUNGHIDUONG.MaKND and Thoigian BETWEEN @t1 AND @t2
	group by PHIEUDANGKY.MaKND, TenKND 
	order by SUM(SoNguoiLon) + SUM(SoTreEm) desc
end
GO
/****** Object:  StoredProcedure [dbo].[usp_KND_KH_MIN]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [dbo].[usp_KND_KH_MIN]
	@t1 date,
	@t2 date
AS
Begin 
	select top 3 PHIEUDANGKY.MaKND, TenKND, SUM(SoNguoiLon) + SUM(SoTreEm) as 'So khach hang'
	from PHIEUDANGKY, KHUNGHIDUONG
	where PHIEUDANGKY.MaKND = KHUNGHIDUONG.MaKND and Thoigian BETWEEN @t1 AND @t2
	group by PHIEUDANGKY.MaKND, TenKND 
	order by SUM(SoNguoiLon) + SUM(SoTreEm)
end
GO
/****** Object:  StoredProcedure [dbo].[usp_LP_CHON_MAX]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [dbo].[usp_LP_CHON_MAX]
	@MaKND nchar(10),
	@t1 date,
	@t2 date
AS
Begin 
	select top 5 LOAIPHONG.MaLP, TenLP, sum(soluong) as 'So luot chon'
	from LOAIPHONG, PHIEUDANGKY, DKLOAIPHONG
	where PHIEUDANGKY.MaKND = @MaKND and Thoigian BETWEEN @t1 AND @t2 and LOAIPHONG.MaLP = DKLOAIPHONG.MaLP and PHIEUDANGKY.MaPDK = DKLOAIPHONG.MaPDK
	group by LOAIPHONG.MaLP, TenLP
	order by sum(soluong) desc
end
GO
/****** Object:  StoredProcedure [dbo].[usp_LP_CHON_MIN]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [dbo].[usp_LP_CHON_MIN]
	@MaKND nchar(10),
	@t1 date,
	@t2 date
AS
Begin 
	select top 5 LOAIPHONG.MaLP, TenLP, sum(soluong) as 'So luot chon'
	from LOAIPHONG, PHIEUDANGKY, DKLOAIPHONG
	where PHIEUDANGKY.MaKND = @MaKND and Thoigian BETWEEN @t1 AND @t2 and LOAIPHONG.MaLP = DKLOAIPHONG.MaLP and PHIEUDANGKY.MaPDK = DKLOAIPHONG.MaPDK
	group by LOAIPHONG.MaLP, TenLP
	order by sum(soluong) 
end
GO
/****** Object:  StoredProcedure [dbo].[usp_PHUTHU]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_PHUTHU](
@MaHD INT,
@GiuongPhu BIT)
AS 
BEGIN
    DECLARE @check_insom MONEY,
            @check_outmuon MONEY,
            @nl INT,
            @te INT,
	        @chiphind MONEY,
			@MaKND NCHAR(10),
			@MaGND NCHAR(10);
	SET @MaKND = (SELECT MaKND FROM PHIEUDANGKY P, HOADON H WHERE P.MaPDK = H.MaPDK AND MaHD = @MaHD);
	SET @MaGND = (SELECT MaGND FROM PHIEUDANGKY P, HOADON H WHERE P.MaPDK = H.MaPDK AND MaHD = @MaHD);
	SET @chiphind = dbo.fu_CHIPHIND((SELECT MaPDK FROM HOADON WHERE MaHD = @MaHD));
    IF (SELECT [TGCheck-in] FROM HOADON WHERE MaHD = @MaHD) < '6:00:00'
	    SET @check_insom = @chiphind;
	ELSE
	BEGIN
    	IF (SELECT [TGCheck-in] FROM HOADON WHERE MaHD = @MaHD) < '12:00:00'
	        SET @check_insom = @chiphind/2;
		ELSE
		    SET @check_insom = 0;
	END
	PRINT 'PHI CHECK-IN SOM:'+STR(@check_insom);
	IF (SELECT [TGCheck-out] FROM HOADON WHERE MaHD = @MaHD) > '21:00:00'
	    SET @check_outmuon = @chiphind;
    ELSE
	BEGIN
    	IF (SELECT [TGCheck-out] FROM HOADON WHERE MaHD = @MaHD) > '12:00:00'
	        SET @check_outmuon = @chiphind/2;
		ELSE 
		    SET @check_outmuon = 0;
	END
	PRINT 'PHI CHECK-OUT MUON:'+STR(@check_outmuon);
	SET @nl = (SELECT H.SoNguoiLon - P.SoNguoiLon FROM HOADON H, PHIEUDANGKY P WHERE MaHD = @MaHD AND H.MaPDK = P.MaPDK);
	IF @nl < 0
	    SET @nl = 0;
	SET @nl = @nl*(SELECT GiaPT FROM GIAPT WHERE MaKND = @MaKND AND MaGND = @MaGND AND TenPT = 'NL');
	PRINT 'PHI PHU THU NGUOI LON:'+STR(@nl);
	SET @te = (SELECT H.SoTreEm - P.SoTreEm FROM HOADON H, PHIEUDANGKY P WHERE MaHD = @MaHD AND H.MaPDK = P.MaPDK);
	IF @te < 0
	    SET @te = 0;
	IF @GiuongPhu = 0
	BEGIN
	    SET @te = @te*(SELECT GiaPT FROM GIAPT WHERE MaKND = @MaKND AND MaGND = @MaGND  AND TenPT = 'TE');
		PRINT 'PHI PHU THU TRE EM:'+STR(@te);
	END
    ELSE
	BEGIN
	    SET @te = @te*(SELECT GiaPT FROM GIAPT WHERE MaKND = @MaKND AND MaGND = @MaGND  AND TenPT = 'GP');
		PRINT 'PHI KE GIUONG PHU TRE EM:'+STR(@te);
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TANGTRUONG]    Script Date: 10/27/2021 12:32:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[usp_TANGTRUONG](
@MaKND NCHAR(10),
@nam int)
AS
BEGIN
    declare @doanhthu money,
			@doanhthu1 money = 0,
			@tangtruong float,
	        @ngay date = '1/1/2000';
	set @ngay = dateadd(year,@nam - 2000,@ngay)
	while year(@ngay) = @nam and dateadd(month,1,@ngay) < GETDATE()
	begin 
	    set @doanhthu = dbo.fu_DOANHTHU(@MaKND,@ngay,dateadd(month,1,@ngay))
		set @tangtruong = 999999999
		if @doanhthu is null
		    set @doanhthu = 0
		if @doanhthu1 != 0
		    set @tangtruong = (@doanhthu-@doanhthu1)*100/@doanhthu1;
	    print 'Thang'+str(month(@ngay))+', Doanh Thu:'+str(@doanhthu)+', Tang Truong:'+str(@tangtruong)+'%';
		set @ngay = dateadd(month,1,@ngay);
		set @doanhthu1 = @doanhthu;
	end
END
GO
