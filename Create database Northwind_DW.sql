

-----------------------------------Create database Northwind_DW--------------------------------------------------------------------------------------



Use master
go


IF EXISTS(select * from sys.databases where name='Northwind_DW')
DROP DATABASE Northwind_DW
go

Create database Northwind_DW
COLLATE SQL_Latin1_General_CP1_CI_AS
go

Use Northwind_DW
go



CREATE TABLE [dbo].[Dim_Products](
	[ProductSK] [int] identity(100,1) PRIMARY KEY NOT NULL,
	[ProductBK] [int] NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[ProductUnitPrice] [money] NULL,
	ProductType nvarchar(20),
	
	[CategoryName] [nvarchar](15) NOT NULL,
	[SupplierName] [nvarchar](40) NOT NULL,

	[Discontinued] [bit] NOT NULL
)



CREATE TABLE [dbo].[Dim_Employees](
	[EmployeeSK] [int] identity(100,1) PRIMARY KEY NOT NULL,
	[EmployeeBK] [int] NOT NULL,

	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[FullName] [nvarchar](32) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[BirthDate] [datetime] NULL,
	Age int null,
	[HireDate] [datetime] NULL,
	Seniority int null,
	[City] [nvarchar](15) NULL,
	[Country] [nvarchar](15) NULL,
	[Photo] [image] NULL,
	[ReportsTo] [int] NULL
)




CREATE TABLE [dbo].[Dim_Customers](
	[CustomerSK] int identity(100,1) PRIMARY KEY NOT NULL,
	[CustomerBK] [nchar](5) NOT NULL,
	[CustomerName] [nvarchar](40) NOT NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[Country] [nvarchar](15) NULL
)




CREATE TABLE [dbo].[Dim_Orders](
	[OrderSK] [int] identity(100,1) PRIMARY KEY NOT NULL,
	[OrderBK] [int] NOT NULL,
	[ShipCity] [nvarchar](15) NULL,
	[ShipRegion] [nvarchar](15) NULL,
	[ShipCountry] [nvarchar](15) NULL
 )
 





 CREATE TABLE [dbo].[Fact_Sales](
	SalesSK int identity(100,1) PRIMARY KEY not null,
	[OrderSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[DateKey] [int] NOT NULL,
	[CustomerSK] [int] NOT NULL,
	[EmployeeSK] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL
)



