USE olist_dwh;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    -- Load Customers
    TRUNCATE TABLE bronze.customers;
    BULK INSERT bronze.customers
    FROM 'C:\Users\Shivranjini\Desktop\Ammu\olist-ecommerce-dwh\datasets\olist_customers_dataset.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Customers loaded successfully';

    -- Load Orders
    TRUNCATE TABLE bronze.orders;
    BULK INSERT bronze.orders
    FROM 'C:\Users\Shivranjini\Desktop\Ammu\olist-ecommerce-dwh\datasets\olist_orders_dataset.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Orders loaded successfully';

    -- Load Order Items
    TRUNCATE TABLE bronze.order_items;
    BULK INSERT bronze.order_items
    FROM 'C:\Users\Shivranjini\Desktop\Ammu\olist-ecommerce-dwh\datasets\olist_order_items_dataset.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Order Items loaded successfully';

    -- Load Order Payments
    TRUNCATE TABLE bronze.order_payments;
    BULK INSERT bronze.order_payments
    FROM 'C:\Users\Shivranjini\Desktop\Ammu\olist-ecommerce-dwh\datasets\olist_order_payments_dataset.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Order Payments loaded successfully';

    -- Load Order Reviews
    TRUNCATE TABLE bronze.order_reviews;
    BULK INSERT bronze.order_reviews
    FROM 'C:\Users\Shivranjini\Desktop\Ammu\olist-ecommerce-dwh\datasets\olist_order_reviews_dataset.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = '65001',
        MAXERRORS = 1000,
        TABLOCK
    );
    PRINT 'Order Reviews loaded successfully';

    -- Load Products
    TRUNCATE TABLE bronze.products;
    BULK INSERT bronze.products
    FROM 'C:\Users\Shivranjini\Desktop\Ammu\olist-ecommerce-dwh\datasets\olist_products_dataset.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Products loaded successfully';

    -- Load Sellers
    TRUNCATE TABLE bronze.sellers;
    BULK INSERT bronze.sellers
    FROM 'C:\Users\Shivranjini\Desktop\Ammu\olist-ecommerce-dwh\datasets\olist_sellers_dataset.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Sellers loaded successfully';

    -- Load Category Translation
    TRUNCATE TABLE bronze.category_translation;
    BULK INSERT bronze.category_translation
    FROM 'C:\Users\Shivranjini\Desktop\Ammu\olist-ecommerce-dwh\datasets\product_category_name_translation.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Category Translation loaded successfully';

END;
GO