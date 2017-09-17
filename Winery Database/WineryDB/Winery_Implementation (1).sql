/*
Alex George, Janani Kumar, Lauren Califano
INFX 543
Database Implementation
*/

CREATE DATABASE "WINERY"
GO

USE WINERY;

CREATE TABLE Winery
	(Winery_ID INT IDENTITY NOT NULL PRIMARY KEY,
	Winery_Name varchar(50) NOT NULL,
	Winery_Website varchar(60) NOT NULL,
	Winery_Phone varchar(10) NOT NULL,
	Winery_City varchar(30) NOT NULL,
	Winery_ZIP INT NOT NULL,
	Winery_Club varchar(1),
	CHECK (Winery_Club IN ('Y','N')),
	Winery_Club_Discount DEC(3,2));	
	
CREATE TABLE Wine
	(Wine_ID INT IDENTITY NOT NULL PRIMARY KEY,
	Wine_Label varchar(50) NOT NULL);

CREATE TABLE Customer
	(Customer_ID INT IDENTITY NOT NULL PRIMARY KEY,
	Customer_Type varchar(200) NOT NULL,
	CHECK (Customer_Type IN ('Winery','Retailer','Restaurant')),
	Customer_Name varchar(200) NOT NULL,
	Customer_ZIP varchar(5) NOT NULL,
	Customer_Website varchar(200) NOT NULL,
	Customer_Phone varchar(10) NOT NULL,
	Customer_City varchar(200) NOT NULL);

CREATE TABLE AVA 
	(AVA_ID INT IDENTITY NOT NULL PRIMARY KEY,
	AVA_Name varchar(50) NOT NULL,
	AVA_Total_Acreage varchar(50) NOT NULL);

CREATE TABLE Vineyard
	(Vineyard_ID INT IDENTITY NOT NULL PRIMARY KEY,
	AVA_ID INT NOT NULL REFERENCES dbo.AVA(AVA_ID),
	Vineyard_Name varchar(50) NOT NULL);	

CREATE TABLE Winery_Source_Vineyards
	(Vineyard_ID INT NOT NULL REFERENCES dbo.Vineyard(Vineyard_ID),
	Winery_ID INT NOT NULL REFERENCES dbo.Winery(Winery_ID),
	PRIMARY KEY (Vineyard_ID, Winery_ID)); 

CREATE TABLE Winery_Wine
	(Winery_ID INT NOT NULL REFERENCES dbo.Winery(Winery_ID),
	Wine_ID INT NOT NULL REFERENCES dbo.Wine(Wine_ID),
	PRIMARY KEY (Winery_ID, Wine_ID)); 

CREATE TABLE Grape_Varietal
	(Grape_Varietal_ID INT IDENTITY NOT NULL PRIMARY KEY,
	Grape_Varietal_Type varchar(5) NOT NULL,
	CHECK (Grape_Varietal_Type IN ('Red','White')),
	Grape_Varietal_Name varchar(30) NOT NULL);

CREATE TABLE Wine_Grape_Varietals
	(Grape_Varietal_ID INT NOT NULL REFERENCES dbo.Grape_Varietal(Grape_Varietal_ID),
	Wine_ID INT NOT NULL REFERENCES dbo.Wine(Wine_ID),
	PRIMARY KEY (Wine_ID, Grape_Varietal_ID)); 


CREATE TABLE Price_Customer
	(Customer_ID INT NOT NULL REFERENCES dbo.Customer(Customer_ID),
	Wine_ID INT NOT NULL REFERENCES dbo.Wine(Wine_ID),
	PRIMARY KEY (Customer_ID, Wine_ID),
	Bottle_Price MONEY NOT NULL,
	Case_Price MONEY NOT NULL,
	Glass_Price MONEY NOT NULL
	); 		
	
CREATE TABLE Vineyard_Grape_Varietals
	(Vineyard_ID INT NOT NULL REFERENCES dbo.Vineyard(Vineyard_ID),
	Grape_Varietal_ID INT NOT NULL REFERENCES dbo.Grape_Varietal(Grape_Varietal_ID),
	PRIMARY KEY (Vineyard_ID, Grape_Varietal_ID)); 				
	
--Creatinf master database key
create master key
encryption by password = 'Test123@'
--creating certificate
create certificate WineryCert
with subject = 'Winery encryption certificate',
expiry_date='2026-10-11';
--creating symmetric key
create symmetric key WinerykeySym
with algorithm=aes_128
encryption by certificate WineryCert
--Opening key
open symmetric key WinerykeySym
decryption by certificate WineryCert

set identity_insert Customer On

insert into Customer
(
	Customer_ID ,
	Customer_Type,
	Customer_Name ,
	Customer_ZIP ,
	Customer_Website ,
	Customer_Phone ,
	Customer_City 
	)
Values
(
ENCRYPTBYKEY(key_guid(N'WinerykeySym'),'-1'),
'Retailer',
ENCRYPTBYKEY(key_guid(N'WinerykeySym'),'null'),
ENCRYPTBYKEY(key_guid(N'WinerykeySym'),'-1'),
ENCRYPTBYKEY(key_guid(N'WinerykeySym'),'null'),
ENCRYPTBYKEY(key_guid(N'WinerykeySym'),'-1'),
ENCRYPTBYKEY(key_guid(N'WinerykeySym'),'-null')
);

--To extract customer names and the wines they sell with their prices

create view View1 as
Select c.customer_name, p.wine_id,p.Bottle_Price,p.Case_Price,p.Glass_Price
from customer c inner join price_customer p
on c.Customer_ID=p.Customer_ID

--To view customer names with the wine labels they sell and the prices
create view view2 as
select v.customer_name,w.wine_label,v.bottle_price,v.case_price,v.glass_price
from View1 v inner join Wine w on v.Wine_ID=w.Wine_ID

select * from view2

-- Inserting Data

INSERT dbo.Winery
VALUES
	('White Heron Cellars','http://www.whiteheronwine.com/','5097979463','Quincy','98848','Y','0.12'),
	('Domaine Pouillon','http://www.domainepouillon.com/','5093652795','Lyle','98635','Y','0.15'),
	('14 Hands','https://www.14hands.com/','8003010773','Prosser','99350','Y','0.2'),
	('Columbia Crest','https://www.columbiacrest.com/','8883099463','Paterson','99345','Y','0.2'),
	('Chateau St. Michelle','https://www.ste-michelle.com/','4254881133','Woodinville','98072','Y','0.25')
	('Tildio Winery','https://www.tildio.com/','5096878463','Manson','98831','Y','0.2'),
	('Frichette Winery','http://frichettewinery.com/','5094263227','Benton City','99320','Y','0.15'),
	('The Hogue Cellars','http://www.hoguecellars.com/','5097866108','Prosser','99350','Y','0'),
	('Canoe Ridge Vineyard','http://canoeridgevineyard.com/','5095270885','Walla Walla','99362','Y','0.2'),
	('Portteus','http://www.portteus.com/','5098296970','Zillah','98953','N','0');

INSERT dbo.Wine
VALUES
	('2005 Pinot Noir'),
	('2012 Cabernet Sauvignon'),
	('2015 Cabernet Sauvignon'),
	('2012 Grand Estates Cabernet Sauvignon'),
	('2015 Reisling')
	('2016 Sauvignon Blanc'),
	('2013 Merlot'),
	('2014 Gewurztraminer'),
	('2015 The Expedition Chardonnay'),
	('2012 Viognier');

INSERT dbo.AVA
VALUES
	('Ancient Lakes','162,762'),
	('Columbia Gorge','191,000'),
	('Columbia Valley','11,000,000'),
	('Horse Heaven Hills','570,000'),
	('Lake Chelan','24,040'),
	('Lewis-Clark Valley','306,658'),
	('Naches Heights','13,254'),
	('Puget Sound','92'),
	('Rattlesnake Hills','68,500'),
	('Red Mountain','4,040'),
	('Snipes Mountain','4,145'),
	('Yakima Valley','13,215'),
	('Wahluke Slope','81,000'),
	('Walla Walla Valley','2,964');

INSERT dbo.Vineyard
VALUES
	('1','Mariposa Vineyard'),
	('2','McDufee Vineyard'),
	('3','14 Hands Vineyard'),
	('4','Columbia Crest Vineyard'),
	('3','Chateau St. Michelle Vineyard'),
	('5','Tildio Vineyard'),
	('10','Gamache Vineyard'),
	('12','Hogue Vineyard'),
	('14','Canoe Ridge Vineyard'),
	('9','Portteus Vineyard');

INSERT dbo.Grape_Varietal
VALUES
	('Red','Pinot Noir'),
	('Red','Cabernet Sauvignon'),
	('White','Reisling'),
	('White','Chardonnay'),
	('Red','Cabernet Franc'),
	('White','Viognier'),
	('Red','Merlot'),
	('White','Sauvignon Blanc'),
	('White','Roussanne'),
	('White','Marsanne');
	
set identity_insert Customer Off

INSERT dbo.Customer
VALUES
	('Winery','Domaine Pouillon','98635','http://www.domainepouillon.com/','5093652795','Lyle'),
	('Winery','14 Hands Winery','99350','https://www.14hands.com/','8003010773','Prosser'),
	('Retailer','QFC','98199','https://www.qfc.com/','2062833600','Seattle'),
	('Retailer','Bartell Drugs','98199','https://www.bartelldrugs.com/','2062822881','Seattle'),
	('Restaurant','Buca di Beppo','98109','http://www.bucadibeppo.com/','2062442288','Seattle'),
	('Winery','Chateau St. Michelle','98072','https://www.ste-michelle.com/','4254881133','Woodinville'),
	('Winery','Tildio Winery','98831','https://www.tildio.com/','5096878463','Manson'),
	('Winery','Frichette Winery','99320','http://frichettewinery.com/','5094263227','Benton City'),
	('Winery','The Hogue Cellars','99350','http://www.hoguecellars.com/','5097866108','Prosser'),
	('Retailer','Marketview Liquor Inc','14623','https://www.marketviewliquor.com/','8884272480','Rochester, NY'),
	('Winery','Canoe Ridge Vineyard','99362','http://canoeridgevineyard.com/','5095270885','Walla Walla'),
	('Winery','Portteus','98953','http://www.portteus.com/','5098296970','Zillah');
	
INSERT dbo.Price_Customer
VALUES
	('4','2',38.00,0,0),
	('5','3',12.00,122.40,0),
	('6','3',11.99,0,0),
	('7','4',7.99,0,0),
	('8','5',38.00,0,11.00),
	('9','5',9.00,91.80,0),
	('11','6',25.00,300.00,0),
	('12','7',37.00,444.00,0),
	('13','8',10.00,120.00,0),
	('14','8',9.49,0,0),
	('15','9',15.00,180.00,0),
	('16','10',15.00,162.00,0);
