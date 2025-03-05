-- 1. Crear la base de datos y usarla
DROP DATABASE IF EXISTS store_inventory;
CREATE DATABASE store_inventory;
USE store_inventory;

-- 2. Crear la tabla store_inventory
CREATE TABLE store_inventory (
    Transaction_ID INT AUTO_INCREMENT PRIMARY KEY,
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

-- 4. Se desactiva la actualizacion
SET SQL_SAFE_UPDATES = 0;

-- 5. Cargar datos desde el CSV

-- Si se usa MySQL la ruta es: 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/new_retail_data.csv' :
-- Si se usa phpMyAdmin la ruta es: 'C:/xampp/mysql/data/new_retail_data.csv'
-- Si se usa DBeaver la ruta es: 'C:/Users/tu_usuario/Documents/new_retail_data.csv'
-- Si se usa phpMyAdmin la ruta es: 'C:/xampp/mysql/data/new_retail_data.csv'

-- Se remplaza 'ruta/archivo/new_retail_data.csv' (Recueda colocar el archivo en la ruta)
LOAD DATA INFILE 'ruta/archivo/new_retail_data.csv' 
INTO TABLE store_inventory
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(@Transaction_ID, @Customer_ID, @Name, @Email, @Phone, @Address, @City, @State, @Zipcode, @Country, @Age, @Gender, @Income, @Customer_Segment, @Date, @Year, @Month, @Time, @Total_Purchases, @Amount, @Total_Amount, @Product_Category, @Product_Brand, @Product_Type, @Feedback, @Shipping_Method, @Payment_Method, @Order_Status, @Ratings, @Products)
SET 
    State = NULLIF(@State, ''),
    Country = NULLIF(@Country, ''),
    Age = NULLIF(@Age, ''),
    Gender = NULLIF(@Gender, ''),
    Income = NULLIF(@Income, ''),
    Customer_Segment = NULLIF(@Customer_Segment, ''),
    Date = IF(@Date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$', STR_TO_DATE(@Date, '%m/%d/%Y'), NULL), -- Validación segura de fecha
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

-- 4. Actualizar valores de Subcategory según la clasificación
UPDATE store_inventory SET Subcategory = 'Speculative Fiction' WHERE Subcategory IN ('Fantasy', 'Science Fiction', 'Dystopian');
UPDATE store_inventory SET Subcategory = 'Realistic Fiction' WHERE Subcategory IN ('Literary Fiction', 'Historical Fiction');
UPDATE store_inventory SET Subcategory = 'Genre Fiction' WHERE Subcategory IN ('Adventure', 'Horror', 'Mystery', 'Romance', 'Action');
UPDATE store_inventory SET Subcategory = 'Life Writing' WHERE Subcategory IN ('Biography', 'Memoir');
UPDATE store_inventory SET Subcategory = 'Professional & Academic' WHERE Subcategory IN ('Business', 'Psychology', 'Science');
UPDATE store_inventory SET Subcategory = 'Practical & Lifestyle' WHERE Subcategory IN ('Cooking', 'Health', 'Self-help', 'Travel');
UPDATE store_inventory SET Subcategory = 'Thriller' WHERE Subcategory IN ('Crime', 'Detective', 'Legal Thriller', 'Political Thriller', 'Techno-thriller', 'Psychological Thriller', 'Suspense');
UPDATE store_inventory SET Subcategory = 'Classical/Canonical' WHERE Subcategory IN ('Classic Literature', 'Drama', 'Poetry');
UPDATE store_inventory SET Subcategory = 'Modern/Contemporary' WHERE Subcategory IN ('Contemporary Literature', 'Modern Literature', 'Short Stories');
UPDATE store_inventory SET Subcategory = 'Forms & Styles' WHERE Subcategory IN ('Anthologies', 'Essays');

-- 7. Corregir nombres de Product_Brand
UPDATE store_inventory SET Product_Brand = 'Mitsubishi' WHERE Product_Brand = 'Mitsubhisi';
UPDATE store_inventory SET Product_Brand = 'Whirlpool' WHERE Product_Brand = 'Whirepool';

-- 8. Reemplazar Areas con Product_Type siempre que Areas es 'Home Decor'
UPDATE store_inventory
SET Areas = Product_Type
WHERE Areas = 'Home Decor';

-- 9. Si Product_Type es 'Children\'s' y Products es 'Books', cambiar Areas a 'Children's'
UPDATE store_inventory
SET Areas = 'Children\'s'
WHERE Product_Type = 'Children\'s' AND Products = 'Books';

-- 10. Si Areas es 'Children's', eliminar el valor de Subcategory
UPDATE store_inventory
SET Subcategory = NULL
WHERE Areas = 'Children\'s';

-- 11. Mover Products a Subcategory en ciertas condiciones
UPDATE store_inventory
SET Subcategory = Products
WHERE Areas IN ('Clothing', 'Grocery');

UPDATE store_inventory
SET Subcategory = Products
WHERE Areas = 'Electronics' 
AND Product_Brand NOT IN ('Apple', 'Samsung', 'Sony') 
AND Product_Brand IS NOT NULL;

-- 12. Asignar Product_Type a Products en ciertas condiciones
UPDATE store_inventory
SET Products = Product_Type
WHERE Areas IN ('Clothing', 'Grocery');

UPDATE store_inventory
SET Products = Product_Type
WHERE Areas = 'Electronics' 
AND Product_Brand NOT IN ('Apple', 'Samsung', 'Sony') 
AND Product_Brand IS NOT NULL;

-- 13. Se realizan las inserciones a cada tabla

--  Insertar datos en Location (Evitar duplicados)
INSERT INTO Location (State, Country)
SELECT DISTINCT State, Country FROM store_inventory;

-- Insertar datos en Product (Evitar duplicados)
INSERT INTO Product (Subcategory, Areas, Products, Brand)
SELECT DISTINCT Subcategory, Areas, Products, Product_Brand FROM store_inventory;

-- Insertar datos en Customer (Usar Location_Id como FK)
INSERT INTO Customer (Location_Id, Age, Gender, Income, Segment)
SELECT DISTINCT 
    (SELECT Location_Id FROM Location WHERE store_inventory.State = Location.State AND store_inventory.Country = Location.Country),
    Age, Gender, Income, Customer_Segment 
FROM store_inventory;

-- Insertar datos en Transaction (Usar Customer_Id y Product_Id como FK)
INSERT INTO Transaction (Customer_Id, Product_Id, Date, Time, Total, Amount, Feedback, Payment, Status, Ratings)
SELECT 
    (SELECT Customer_Id FROM Customer WHERE store_inventory.Age = Customer.Age AND store_inventory.Gender = Customer.Gender AND store_inventory.Income = Customer.Income AND store_inventory.Customer_Segment = Customer.Segment LIMIT 1),
    (SELECT Product_Id FROM Product WHERE store_inventory.Products = Product.Products AND store_inventory.Product_Brand = Product.Brand AND store_inventory.Areas = Product.Areas LIMIT 1),
    Date, Time, Total_Purchases, Amount, Feedback, Payment_Method, Order_Status, Ratings 
FROM store_inventory
LIMIT 100000;

-- 14. Se elimina store_inventory porque ya no se va a usar
DROP TABLE IF EXISTS store_inventory;

-- Se reactiva la actualizacion segura
SET SQL_SAFE_UPDATES = 1;

