
bq query --use_legacy_sql=false SELECT DISTINCT products.product_name,products.price FROM Inventory.products INNER JOIN Inventory.category ON products.category_id = category.category_id WHERE products.category_id = 1;

bq mk --use_legacy_sql=false --view 'SELECT DISTINCT products.product_name,products.price FROM Inventory.products INNER JOIN Inventory.category ON products.category_id = category.category_id WHERE products.category_id = 1;' Inventory.Product_View
