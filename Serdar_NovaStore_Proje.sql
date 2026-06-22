/*
    Proje: NovaStore E-Ticaret Veri Yonetim Sistemi
    Hazirlayan: Sidar Demir
    Platform: Microsoft SQL Server (T-SQL)
*/

-- =========================================================
-- BOLUM 1: VERI TABANI TASARIMI (DDL)
-- =========================================================

-- Gorev 1: NovaStoreDB veri tabanini olusturma
IF DB_ID('NovaStoreDB') IS NULL
BEGIN
    CREATE DATABASE NovaStoreDB COLLATE Turkish_CI_AS;
END;
GO

USE NovaStoreDB;
GO

-- Scriptin tekrar calistirilabilmesi icin once view ve tablolar silinir.
IF OBJECT_ID('dbo.vw_SiparisOzet', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SiparisOzet;
GO

IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
GO

-- A. Categories tablosu
CREATE TABLE dbo.Categories
(
    CategoryID   INT IDENTITY(1,1) NOT NULL,
    CategoryName VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT UQ_Categories_CategoryName UNIQUE (CategoryName)
);
GO

-- C. Customers tablosu (ana tablo oldugu icin Products ve Orders'tan once olusturulur)
CREATE TABLE dbo.Customers
(
    CustomerID INT IDENTITY(1,1) NOT NULL,
    FullName   VARCHAR(50) NOT NULL,
    City       VARCHAR(20) NOT NULL,
    Email      VARCHAR(100) NOT NULL,

    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)
);
GO

-- B. Products tablosu
CREATE TABLE dbo.Products
(
    ProductID   INT IDENTITY(1,1) NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Stock       INT NOT NULL CONSTRAINT DF_Products_Stock DEFAULT (0),
    CategoryID  INT NOT NULL,

    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    CONSTRAINT CK_Products_Stock CHECK (Stock >= 0),
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID)
);
GO

-- D. Orders tablosu
CREATE TABLE dbo.Orders
(
    OrderID     INT IDENTITY(1,1) NOT NULL,
    CustomerID  INT NOT NULL,
    OrderDate   DATETIME NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT (GETDATE()),
    TotalAmount DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
    CONSTRAINT CK_Orders_TotalAmount CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);
GO

-- E. OrderDetails ara tablosu
CREATE TABLE dbo.OrderDetails
(
    DetailID INT IDENTITY(1,1) NOT NULL,
    OrderID  INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,

    CONSTRAINT PK_OrderDetails PRIMARY KEY (DetailID),
    CONSTRAINT CK_OrderDetails_Quantity CHECK (Quantity > 0),
    CONSTRAINT UQ_OrderDetails_Order_Product UNIQUE (OrderID, ProductID),
    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);
GO

-- =========================================================
-- BOLUM 2: ORNEK VERI GIRISI (DML - INSERT)
-- =========================================================

-- Gorev 1: 5 kategori ekleme
INSERT INTO dbo.Categories (CategoryName)
VALUES
(N'Elektronik'),
(N'Giyim'),
(N'Kitap'),
(N'Kozmetik'),
(N'Ev ve Yaşam');
GO

-- Gorev 2: Toplam 12 urun ekleme
INSERT INTO dbo.Products (ProductName, Price, Stock, CategoryID)
VALUES
(N'Dizüstü Bilgisayar',       28500.00,  8, 1),
(N'Kablosuz Kulaklık',         1850.00, 18, 1),
(N'Akıllı Saat',               3200.00, 14, 1),
(N'Erkek Mont',                2450.00, 12, 2),
(N'Kadın Spor Ayakkabı',       1750.00, 25, 2),
(N'Basic Tişört',               450.00, 40, 2),
(N'SQL ile Veri Tabanı',        780.00, 16, 3),
(N'Modern Roman',               320.00, 30, 3),
(N'Cilt Bakım Seti',            950.00,  9, 4),
(N'Parfüm',                    1350.00, 22, 4),
(N'Kahve Makinesi',            4200.00,  7, 5),
(N'Masa Lambası',               690.00, 19, 5);
GO

-- Gorev 3: 6 musteri ekleme
INSERT INTO dbo.Customers (FullName, City, Email)
VALUES
(N'Ahmet Yılmaz',  N'İstanbul',  'ahmet.yilmaz@novastore.test'),
(N'Ayşe Demir',    'Ankara',    'ayse.demir@novastore.test'),
(N'Mehmet Kaya',   N'İzmir',     'mehmet.kaya@novastore.test'),
(N'Elif Şahin',    'Bursa',     'elif.sahin@novastore.test'),
(N'Can Aydın',     'Antalya',   'can.aydin@novastore.test'),
(N'Zeynep Koç',    N'Eskişehir', 'zeynep.koc@novastore.test');
GO

-- Gorev 4: Farkli tarihlerde 10 siparis ekleme
INSERT INTO dbo.Orders (CustomerID, OrderDate, TotalAmount)
VALUES
(1, '2026-06-01T10:15:00', 29280.00),
(2, '2026-06-03T14:20:00',  2700.00),
(3, '2026-06-05T11:45:00',  6900.00),
(4, '2026-06-07T16:10:00',  3350.00),
(5, '2026-06-09T09:30:00',  5580.00),
(6, '2026-06-11T13:05:00',  2310.00),
(1, '2026-06-13T17:40:00',  5050.00),
(2, '2026-06-15T12:25:00',  2250.00),
(3, '2026-06-17T15:50:00',  3250.00),
(4, '2026-06-20T18:00:00', 29850.00);
GO

-- Siparislere ait detaylar
INSERT INTO dbo.OrderDetails (OrderID, ProductID, Quantity)
VALUES
(1,  1, 1), (1,  7, 1),
(2,  5, 1), (2,  9, 1),
(3,  2, 2), (3,  3, 1),
(4,  4, 1), (4,  6, 2),
(5, 11, 1), (5, 12, 2),
(6,  8, 3), (6, 10, 1),
(7,  3, 1), (7,  2, 1),
(8,  7, 2), (8, 12, 1),
(9,  9, 2), (9, 10, 1),
(10, 1, 1), (10, 6, 3);
GO

-- Veri tutarliligi kontrolu: detaylardan hesaplanan tutar ile Orders.TotalAmount karsilastirilir.
SELECT
    o.OrderID,
    o.TotalAmount AS KayitliTutar,
    SUM(p.Price * od.Quantity) AS HesaplananTutar,
    CASE
        WHEN o.TotalAmount = SUM(p.Price * od.Quantity) THEN 'UYUMLU'
        ELSE 'KONTROL EDILMELI'
    END AS Kontrol
FROM dbo.Orders AS o
INNER JOIN dbo.OrderDetails AS od ON od.OrderID = o.OrderID
INNER JOIN dbo.Products AS p ON p.ProductID = od.ProductID
GROUP BY o.OrderID, o.TotalAmount
ORDER BY o.OrderID;
GO

-- =========================================================
-- BOLUM 3: SORGULAMA VE ANALIZ (DQL)
-- =========================================================

-- Sorgu 1: Stogu 20'den az urunleri stok miktarina gore azalan siralama
SELECT
    ProductName AS UrunAdi,
    Stock AS StokMiktari
FROM dbo.Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

-- Sorgu 2: Musteri, sehir, siparis tarihi ve toplam tutar raporu
SELECT
    c.FullName AS MusteriAdi,
    c.City AS Sehir,
    o.OrderDate AS SiparisTarihi,
    o.TotalAmount AS ToplamTutar
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate;
GO

-- Sorgu 3: Ahmet Yilmaz'in aldigi urunler, fiyatlari ve kategorileri
SELECT
    p.ProductName AS UrunAdi,
    p.Price AS BirimFiyat,
    cat.CategoryName AS Kategori
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
INNER JOIN dbo.OrderDetails AS od ON od.OrderID = o.OrderID
INNER JOIN dbo.Products AS p ON p.ProductID = od.ProductID
INNER JOIN dbo.Categories AS cat ON cat.CategoryID = p.CategoryID
WHERE c.FullName = N'Ahmet Yılmaz'
ORDER BY o.OrderDate, p.ProductName;
GO

-- Sorgu 4: Her kategoride kac urun bulundugu
SELECT
    cat.CategoryName AS Kategori,
    COUNT(p.ProductID) AS UrunSayisi
FROM dbo.Categories AS cat
LEFT JOIN dbo.Products AS p ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY cat.CategoryName;
GO

-- Sorgu 5: Her musterinin toplam cirosu; en cok harcayandan en aza
SELECT
    c.CustomerID,
    c.FullName AS MusteriAdi,
    COALESCE(SUM(o.TotalAmount), 0) AS ToplamCiro
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY ToplamCiro DESC;
GO

-- Sorgu 6: Siparislerin uzerinden kac gun gectigi
SELECT
    OrderID,
    OrderDate AS SiparisTarihi,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGunSayisi
FROM dbo.Orders
ORDER BY OrderDate;
GO

-- Ek ileri sorgu: Ortalama siparis tutarinin uzerindeki siparisler (Subquery)
SELECT
    o.OrderID,
    c.FullName AS MusteriAdi,
    o.OrderDate,
    o.TotalAmount
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.TotalAmount > (SELECT AVG(TotalAmount) FROM dbo.Orders)
ORDER BY o.TotalAmount DESC;
GO

-- =========================================================
-- BOLUM 4: ILERI SEVIYE VERI TABANI NESNELERI
-- =========================================================

-- Gorev 1: vw_SiparisOzet gorunumunu olusturma
CREATE VIEW dbo.vw_SiparisOzet
AS
SELECT
    c.FullName AS MusteriAdi,
    o.OrderDate AS SiparisTarihi,
    p.ProductName AS UrunAdi,
    od.Quantity AS Adet
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
INNER JOIN dbo.OrderDetails AS od ON od.OrderID = o.OrderID
INNER JOIN dbo.Products AS p ON p.ProductID = od.ProductID;
GO

-- View'i test etme
SELECT *
FROM dbo.vw_SiparisOzet
ORDER BY SiparisTarihi, MusteriAdi;
GO

-- Gorev 2: NovaStoreDB veri tabanini C:\Yedek\ klasorune yedekleme
-- Not: C:\Yedek klasoru onceden olusturulmali ve SQL Server servis hesabinin
-- bu klasore yazma izni bulunmalidir.
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH
    INIT,
    NAME = 'NovaStoreDB Tam Yedek',
    STATS = 10;
GO

-- Opsiyonel yedek dogrulama komutu
RESTORE VERIFYONLY
FROM DISK = 'C:\Yedek\NovaStoreDB.bak';
GO
