use Northwind_DW
go

---Functions----
if OBJECT_ID('Northwind_DW.dbo.fn_productType') is not null
	drop Function dbo.fn_productType

if OBJECT_ID('Northwind_DW.dbo.fn_categoryName') is not null
	drop Function dbo.fn_categoryName

if OBJECT_ID('Northwind_DW.dbo.fn_Date') is not null
	drop Function dbo.fn_Date

if OBJECT_ID('Northwind_DW.dbo.fn_supplierName') is not null
	drop Function dbo.fn_supplierName

if OBJECT_ID('Northwind_DW.dbo.CreateModel') is not null
	drop Procedure dbo.CreateModel
if OBJECT_ID('Northwind_DW.dbo.vv_Sales') is not null
	drop view dbo.vv_Sales
if OBJECT_ID('Northwind_DW.dbo.Dim_Date') is not null
	drop table dbo.Dim_Date
go

create function [dbo].[fn_productType](@productID int)
returns nvarchar (50)
as
begin
	declare @avgPrice int = (select avg(unitprice) from NORTHWND.dbo.Products)
	declare @productUnitPrice int = (select (unitprice) from NORTHWND.dbo.Products where ProductID = @productID)
	if @productUnitPrice > @avgPrice
		declare @type nvarchar(50) = 'Expensive'
	else
		set @type = 'Cheap'
return @type
end
go

create function [dbo].fn_categoryName(@productId int)
returns nvarchar (50)
as
begin
declare @categoryName nvarchar(50) = (select CategoryName
from NORTHWND.dbo.Categories c join NORTHWND.dbo.Products p on
c.CategoryID = p.CategoryID
where p.ProductID = 45)
return @categoryName
end
go

create function [dbo].fn_supplierName(@productId int)
returns nvarchar (50)
as
begin
declare @supplierName nvarchar(50) =  (select CompanyName
from NORTHWND.dbo.Suppliers c join NORTHWND.dbo.Products p on
c.SupplierID = p.SupplierID
where p.ProductID = @productId)
return @supplierName
end
go

create function [dbo].fn_Date(@startDate date,@endDate date)
returns @Dim_Date table
(	
	[DateKey] [int] NOT NULL,
	[Date] [date] NULL,
	[Year] [int] NULL,
	[Quarter] [int] NULL,
	[Month] [int] NULL,
	[MonthName] [nvarchar](20) NULL
)
Begin
declare @currentDate date =  @startDate
while @currentDate <= @endDate
Begin
	insert into @Dim_Date
	values (
			CONVERT(CHAR(8),@currentDate,112),
			@currentDate,
			YEAR(@currentDate),
			DATEPART(QUARTER, @currentDate),
			month(@currentDate),
			DATENAME(month,@currentDate))
	set @currentDate = DATEADD(DAY, 1, @currentDate)
			
end
return
End
go
---Functions----
--Create Dim_Date Table
Create Table Dim_Date
(	
	[DateKey] [int] NOT NULL,
	[Date] [date] NULL,
	[Year] [int] NULL,
	[Quarter] [int] NULL,
	[Month] [int] NULL,
	[MonthName] [nvarchar](20) NULL
)
go

--Create VIEW to easier connect all tables for SK
create view [dbo].vv_Sales
as
select OrderSK,ProductSK,DateKey,CustomerSK,EmployeeSK,UnitPrice,Quantity,Discount
from [NORTHWND].dbo.[Order Details] od join [NORTHWND].dbo.Orders o on
od.OrderID = o.OrderID join
Dim_Orders do 
on do.OrderBK = od.OrderID 
join Dim_Products dp
on dp.ProductBK = od.ProductID
join Dim_Date dd
on dd.Date = o.OrderDate 
join Dim_Customers DC on
dc.CustomerBK = o.CustomerID 
join Dim_Employees de on 
de.EmployeeBK = o.EmployeeID
go



CREATE PROCEDURE CreateModel
As
truncate table Dim_customers
truncate table Dim_date
truncate table Dim_Employees
truncate table Dim_Orders
truncate table Dim_Products
truncate table Fact_Sales

insert into Dim_Customers(CustomerBK,CustomerName,City,Region,Country)
select CustomerID,CompanyName,City,Region,Country
from NORTHWND.dbo.Customers


insert into Dim_Employees(EmployeeBK,LastName,FirstName,FullName,title,BirthDate,age,HireDate,Seniority,City,Country,Photo,ReportsTo
)
select EmployeeID,LastName,FirstName, FirstName + ' ' +LastName, Title,birthdate,
DATEDIFF(year,BirthDate,GETDATE()),HireDate,DATEDIFF(year,HireDate,GETDATE()),City,Country,Photo,ReportsTo
from NORTHWND.dbo.Employees


insert into Dim_Orders(OrderBK,ShipCity,ShipRegion,ShipCountry)
select OrderID,ShipCity,ShipRegion,ShipCountry
from NORTHWND.dbo.Orders


insert into Dim_Products(ProductBK,ProductName,ProductUnitPrice,ProductType,CategoryName,SupplierName,Discontinued)
select ProductID,ProductName,UnitPrice,(select dbo.fn_productType(ProductID)), (select dbo.fn_categoryName(ProductID)),
(select dbo.fn_supplierName(ProductID)), Discontinued
from NORTHWND.dbo.Products

--Fill Dim_Date
insert into Dim_Date (DateKey, [Date],[Year],[Quarter],[Month],[MonthName])
select * 
from dbo.fn_Date('01/01/1996','12/31/1999')


insert into Fact_Sales(OrderSK,ProductSK,DateKey,CustomerSK,EmployeeSK,UnitPrice,Quantity,Discount)
select *
from vv_Sales

Select * from Fact_Sales
Go

exec CreateModel
