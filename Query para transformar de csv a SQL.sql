-- 1. Crear la base de datos y usarla
DROP DATABASE IF EXISTS store_inventory;
CREATE DATABASE store_inventory;
USE store_inventory;

-- 2. Crear la tabla store_inventory
CREATE TABLE store_inventory (
    Transaction_ID INT AUTO_INCREMENT PRIMARY KEY,
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Age INT,
    Gender VARCHAR(50),
    Income VARCHAR(50),
    Customer_Segment VARCHAR(100),
    Date DATE,
    Time TIME,
    Total_Purchases DOUBLE,
    Amount DOUBLE,
    Product_Brand VARCHAR(100),
    Product_Type VARCHAR(100),
    Feedback VARCHAR(255),
    Payment_Method VARCHAR(100),
    Order_Status VARCHAR(100),
    Ratings VARCHAR(50),
    Products VARCHAR(255),
    Areas VARCHAR(100), 
    Subcategory VARCHAR(255) 
);

-- 3. Se crean las tablas
-- Crear la tabla Location
CREATE TABLE Location (
    Location_Id INT AUTO_INCREMENT PRIMARY KEY,
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255)
);

-- Crear la tabla Product
CREATE TABLE Product (
    Product_Id INT AUTO_INCREMENT PRIMARY KEY,
    Subcategory VARCHAR(255),
    Areas VARCHAR(255),
    Products VARCHAR(255),
    Brand VARCHAR(255)
);

-- Crear la tabla Customer
CREATE TABLE Customer (
    Customer_Id INT AUTO_INCREMENT PRIMARY KEY,
    Location_Id INT,
    Age INT,
    Gender VARCHAR(50),
    Income VARCHAR(50),
    Segment VARCHAR(255),
    FOREIGN KEY (Location_Id) REFERENCES Location(Location_Id)
);

-- Crear la tabla Transaction
CREATE TABLE Transaction (
    Transaction_Id INT AUTO_INCREMENT PRIMARY KEY,
    Customer_Id INT,
    Product_Id INT,
    Date DATE,
    Time TIME,
    Total DOUBLE,
    Amount DOUBLE,
    Feedback VARCHAR(255),
    Payment VARCHAR(255),
    Status VARCHAR(255),
    Ratings VARCHAR(50),
    FOREIGN KEY (Customer_Id) REFERENCES Customer(Customer_Id),
    FOREIGN KEY (Product_Id) REFERENCES Product(Product_Id)
);

-- 4. Se desactiva la actualización segura
SET SQL_SAFE_UPDATES = 0;

-- 5. Cargar datos desde el CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/new_retail_data.csv'
INTO TABLE store_inventory
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(@Transaction_ID, @Customer_ID, @Name, @Email, @Phone, @Address, @City, @State, @Zipcode, @Country, @Age, @Gender, @Income, @Customer_Segment, @Date, @Year, @Month, @Time, @Total_Purchases, @Amount, @Total_Amount, @Product_Category, @Product_Brand, @Product_Type, @Feedback, @Shipping_Method, @Payment_Method, @Order_Status, @Ratings, @Products)
SET 
    City = NULLIF(@City, ''),
    State = NULLIF(@State, ''),
    Country = NULLIF(@Country, ''),
    Age = NULLIF(@Age, ''),
    Gender = NULLIF(@Gender, ''),
    Income = NULLIF(@Income, ''),
    Customer_Segment = NULLIF(@Customer_Segment, ''),
    Date = IF(@Date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$', STR_TO_DATE(@Date, '%m/%d/%Y'), NULL),
    Time = NULLIF(@Time, ''),
    Total_Purchases = NULLIF(@Total_Purchases, ''),
    Amount = NULLIF(@Amount, ''),
    Product_Brand = NULLIF(@Product_Brand, ''),
    Product_Type = NULLIF(@Product_Type, ''),
    Feedback = NULLIF(@Feedback, ''),
    Payment_Method = NULLIF(@Payment_Method, ''),
    Order_Status = NULLIF(@Order_Status, ''),
    Ratings = NULLIF(@Ratings, ''),
    Products = CASE WHEN @Product_Category = 'Books' THEN 'Books' ELSE NULLIF(@Products, '') END,
    Areas = CASE WHEN @Product_Category = 'Books' THEN 'Reading' ELSE NULLIF(@Product_Category, '') END,
    Subcategory = CASE WHEN @Product_Category = 'Books' THEN NULLIF(@Products, '') ELSE NULL END;

-- 6. Actualizar valores de Products basándose en Areas
UPDATE store_inventory
SET Products = 'Books'
WHERE Areas = 'Reading';

-- 7. Corregir nombres de Product_Brand
UPDATE store_inventory SET Product_Brand = 'Mitsubishi' WHERE Product_Brand = 'Mitsubhisi';
UPDATE store_inventory SET Product_Brand = 'Whirlpool' WHERE Product_Brand = 'Whirepool';

-- 8. Reemplazar valores en Products
UPDATE store_inventory
SET Products = 'air-conditioning'
WHERE Products IN ('Mitsubishi 1.5 Ton 3 Star Split AC', 'BlueStar AC');

-- 9. Reemplazar Areas con Product_Type siempre que Areas sea 'Home Decor'
UPDATE store_inventory
SET Areas = Product_Type
WHERE Areas = 'Home Decor';

-- 10. Mover la primera palabra de Products a Product_Brand
UPDATE store_inventory
SET 
    Product_Brand = SUBSTRING_INDEX(Products, ' ', 1), -- Extrae la primera palabra
    Products = TRIM(SUBSTRING(Products FROM LOCATE(' ', Products) + 1)) -- Elimina la primera palabra
WHERE Products REGEXP '^(Lenovo|Samsung|Huawei|Amazon|Google|Microsoft|Android|LG|Xiaomi|Razer|Asus|Nokia|Acer|Motorola|Sony)\\b';

UPDATE store_inventory
SET Product_Brand = 'Apple'
WHERE Products IN ('iPad', 'iPhone');

-- 11. Si Product_Type es 'Children\'s' y Products es 'Books', cambiar Areas a 'Children\'s'
UPDATE store_inventory
SET Areas = 'Children\'s'
WHERE Product_Type = 'Children\'s' AND Products = 'Books';

-- 12. Si Areas es 'Children\'s', eliminar el valor de Subcategory
UPDATE store_inventory
SET Subcategory = NULL
WHERE Areas = 'Children\'s';

-- 13. Mover Products a Subcategory en ciertas condiciones
UPDATE store_inventory
SET Subcategory = Products
WHERE Areas IN ('Clothing', 'Grocery');

UPDATE store_inventory
SET Subcategory = Products
WHERE Areas = 'Electronics' 
AND Product_Brand NOT IN ('Apple', 'Samsung', 'Sony') 
AND Product_Brand IS NOT NULL;

-- 14. Asignar Product_Type a Products en ciertas condiciones
UPDATE store_inventory
SET Products = Product_Type
WHERE Areas IN ('Clothing', 'Grocery');

UPDATE store_inventory
SET Products = Product_Type
WHERE Areas = 'Electronics' 
AND Product_Brand NOT IN ('Apple', 'Samsung', 'Sony') 
AND Product_Brand IS NOT NULL;

-- 15. Se realizan las inserciones a cada tabla

-- Insertar datos en Location (Evitar duplicados)
INSERT INTO Location (City, State, Country)
SELECT DISTINCT City, State, Country FROM store_inventory;

-- Insertar datos en Product (Evitar duplicados)
INSERT INTO Product (Subcategory, Areas, Products, Brand)
SELECT DISTINCT Subcategory, Areas, Products, Product_Brand FROM store_inventory;

-- Insertar datos en Customer (Usar Location_Id como FK)
INSERT INTO Customer (Location_Id, Age, Gender, Income, Segment)
SELECT DISTINCT 
    (SELECT Location_Id FROM Location WHERE store_inventory.City = Location.City AND store_inventory.State = Location.State AND store_inventory.Country = Location.Country LIMIT 1),
    Age, Gender, Income, Customer_Segment 
FROM store_inventory;


-- Insertar datos en Transaction (Usar Customer_Id y Product_Id como FK)
INSERT INTO Transaction (Customer_Id, Product_Id, Date, Time, Total, Amount, Feedback, Payment, Status, Ratings)
SELECT 
    (SELECT Customer_Id FROM Customer WHERE store_inventory.Age = Customer.Age AND store_inventory.Gender = Customer.Gender AND store_inventory.Income = Customer.Income AND store_inventory.Customer_Segment = Customer.Segment LIMIT 1),
    (SELECT Product_Id FROM Product WHERE store_inventory.Products = Product.Products AND store_inventory.Product_Brand = Product.Brand AND store_inventory.Areas = Product.Areas LIMIT 1),
    Date, Time, Total_Purchases, Amount, Feedback, Payment_Method, Order_Status, Ratings 
FROM store_inventory;

-- 16. Se elimina store_inventory porque ya no se va a usar
ALTER TABLE Location DROP COLUMN City;
DROP TABLE IF EXISTS store_inventory;

-- Se reactiva la actualización segura
SET SQL_SAFE_UPDATES = 1;
