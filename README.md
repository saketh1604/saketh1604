
# Inventory Restock Tracking System

## Project Description
The **Inventory Restock Tracking System** is a MySQL-based project designed to manage and monitor product inventories. It automatically logs restock events, prevents negative stock levels, and triggers notifications when stock falls below a specified threshold. This system ensures accurate and efficient inventory management in retail or warehouse environments.

## Features
- **Product Stock Management**: Track product stock levels and manage product information.
- **Restock Logging**: Automatically logs restock events when stock is increased.
- **Low Stock Notifications**: Triggers an alert when stock falls below a predefined threshold.
- **Negative Stock Prevention**: Prevents any updates that would result in a negative stock value.
- **Real-Time Monitoring**: Provides real-time data on stock levels and restock events.

## Technologies Used
- **MySQL**: Database management system.
- **SQL**: Queries and triggers to manage stock and generate alerts.

## Database Schema

### Products Table
Stores product information and the current stock levels.
```sql
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL
);
```

### RestockLog Table
Logs restock events, including the product ID, product name, quantity added, and the date/time of the restock.
```sql
CREATE TABLE RestockLog (
    restock_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    product_name VARCHAR(100),
    quantity_added INT,
    restock_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
```

### LowStockNotifications Table
Stores alerts for products that have fallen below the stock threshold.
```sql
CREATE TABLE LowStockNotifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    product_name VARCHAR(100),
    stock_quantity INT,
    alert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
```

## Triggers

### Restock Logging Trigger
Automatically logs restock events in the `RestockLog` table when stock is increased.
```sql
DELIMITER $$

CREATE TRIGGER log_restock
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity > OLD.stock_quantity THEN
        INSERT INTO RestockLog (product_id, product_name, quantity_added)
        VALUES (NEW.product_id, NEW.product_name, NEW.stock_quantity - OLD.stock_quantity);
    END IF;
END $$

DELIMITER ;
```

### Low Stock Notification Trigger
Automatically logs an alert in the `LowStockNotifications` table when the stock falls below a certain threshold (e.g., 10 units).
```sql
DELIMITER $$

CREATE TRIGGER check_low_stock
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    DECLARE stock_threshold INT DEFAULT 10;
    IF NEW.stock_quantity < stock_threshold THEN
        INSERT INTO LowStockNotifications (product_id, product_name, stock_quantity)
        VALUES (NEW.product_id, NEW.product_name, NEW.stock_quantity);
    END IF;
END $$

DELIMITER ;
```

### Negative Stock Prevention Trigger
Prevents stock from going below zero by raising an error if an update tries to set a negative stock quantity.
```sql
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
```

## Installation

### Step 1: Clone the Repository
```bash
git clone https://github.com/your_username/inventory_restock_project.git
cd inventory_restock_project
```

### Step 2: Set Up the Database
1. Open your MySQL client.
2. Run the SQL scripts to set up the tables and triggers:
   - `schema.sql`: Contains the table creation scripts.
   - `triggers.sql`: Contains the trigger definitions.
   - `data_inserts.sql`: Contains sample data for testing.

### Step 3: Running the Project
1. Insert sample products into the `Products` table.
2. Update stock levels to trigger the restock logs or low-stock alerts.
3. Query the `RestockLog` and `LowStockNotifications` tables to monitor restocking and low-stock events.

## Usage

### Insert New Products
```sql
INSERT INTO Products (product_name, stock_quantity)
VALUES ('Laptop', 50), ('Smartphone', 100), ('Tablet', 30);
```

### Update Stock Levels
```sql
UPDATE Products
SET stock_quantity = stock_quantity + 20
WHERE product_id = 1;  -- Restocking 20 units of product with ID 1 (Laptop)
```

### View Restock Logs
```sql
SELECT * FROM RestockLog;
```

### View Low Stock Notifications
```sql
SELECT * FROM LowStockNotifications;
```

## Future Enhancements
- **Email or SMS Notifications**: Integrate email/SMS notifications for low-stock alerts.
- **Admin Dashboard**: Add a user interface to monitor stock levels and manage products.
- **Reporting**: Generate reports on frequent restocks and low-stock events.

