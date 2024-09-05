

CREATE DATABASE InventorySystem;
USE InventorySystem;

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL
);
CREATE TABLE RestockLog (
    restock_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    quantity_added INT,
    restock_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
INSERT INTO Products (product_name, stock_quantity)
VALUES
('Laptop', 50),
('Smartphone', 100),
('Tablet', 30),
('Headphones', 20);
DELIMITER $$

CREATE TRIGGER log_restock
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity > OLD.stock_quantity THEN
        INSERT INTO RestockLog (product_id, quantity_added)
        VALUES (NEW.product_id, NEW.stock_quantity - OLD.stock_quantity);
    END IF;
END $$

DELIMITER ;
UPDATE Products
SET stock_quantity = stock_quantity + 20
WHERE product_id = 1;  -- Adding 20 units to Laptop (product_id = 1)

SELECT * FROM RestockLog;

UPDATE Products
SET stock_quantity = stock_quantity + 90
WHERE product_id = 1;  -- Adding 20 units to Laptop (product_id = 1)

select * from products;



UPDATE Products
SET stock_quantity = stock_quantity + 90
WHERE product_id = 4;

INSERT INTO Products (product_name, stock_quantity)
VALUES ('Smartwatch', 15);

SELECT p.product_name, r.quantity_added, r.restock_date
FROM RestockLog r
JOIN Products p ON r.product_id = p.product_id
ORDER BY r.restock_date DESC;

DELIMITER $$  -- Change delimiter to $$

CREATE TRIGGER prevent_negative_stock
BEFORE UPDATE ON Products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock cannot go below zero';
    END IF;
END $$

DELIMITER ;  -- Reset the delimiter back to the default ;

SHOW TRIGGERS LIKE 'Products';

DELIMITER $$
CREATE TRIGGER prevent_negative_stock
BEFORE UPDATE ON Products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock cannot go below zero';
    END IF;
END $$
DELIMITER ;

UPDATE Products
SET stock_quantity = stock_quantity - 15
WHERE product_id = 1;

UPDATE Products
SET stock_quantity = stock_quantity - 155
WHERE product_id = 1;


CREATE TABLE LowStockNotifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    product_name VARCHAR(100),
    stock_quantity INT,
    alert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


DELIMITER $$

CREATE TRIGGER check_low_stock
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    -- Set the threshold for low stock
    DECLARE stock_threshold INT DEFAULT 10;

    -- Check if the new stock is below the threshold
    IF NEW.stock_quantity < stock_threshold THEN
        -- Insert a low-stock alert into the LowStockNotifications table
        INSERT INTO LowStockNotifications (product_id, product_name, stock_quantity)
        VALUES (NEW.product_id, NEW.product_name, NEW.stock_quantity);
    END IF;
END $$

DELIMITER ;

UPDATE Products
SET stock_quantity = 5
WHERE product_id = 3;

SELECT * FROM LowStockNotifications;


