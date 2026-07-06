CREATE DATABASE bd_santiago_primerapellido_clan;

CREATE TABLE riwi_cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE riwi_suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL UNIQUE,
    city_id INT NOT NULL,
    CONSTRAINT fk_supplier_city
        FOREIGN KEY (city_id)
        REFERENCES riwi_cities(city_id)
);

CREATE TABLE riwi_warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(150) NOT NULL UNIQUE,
    city_id INT NOT NULL,
    CONSTRAINT fk_warehouse_city
        FOREIGN KEY (city_id)
        REFERENCES riwi_cities(city_id)
);

CREATE TABLE riwi_categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE riwi_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL UNIQUE,
    category_id INT NOT NULL,
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES riwi_categories(category_id)
);

CREATE TABLE riwi_inventory_movements (
    movement_id INT PRIMARY KEY,
    movement_date DATE NOT NULL,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL
        CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL
        CHECK (unit_price > 0),
    movement_type VARCHAR(3) NOT NULL
        CHECK (movement_type IN ('IN','OUT')),
    purchase_order VARCHAR(20) NOT NULL,
    CONSTRAINT fk_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES riwi_suppliers(supplier_id),
    CONSTRAINT fk_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES riwi_warehouses(warehouse_id),
    CONSTRAINT fk_product
        FOREIGN KEY (product_id)
        REFERENCES riwi_products(product_id)
);



/* ===========================
   DML - RiwiSupply
   Santiago Otálora Orozco
   PostgreSQL
=========================== */

-- ===========================
-- riwi_cities
-- ===========================

INSERT INTO riwi_cities (city_id, city_name) VALUES
(1,'Cartagena'),
(2,'Barranquilla'),
(3,'Santa Marta');

-- ===========================
-- riwi_suppliers
-- ===========================

INSERT INTO riwi_suppliers (supplier_id,supplier_name,city_id) VALUES
(1,'Aceros del Norte S.A.S',1),
(2,'Industriales S.A.S',2),
(3,'Suministros Global S.A.S',3);

-- ===========================
-- riwi_warehouses
-- ===========================

INSERT INTO riwi_warehouses (warehouse_id,warehouse_name,city_id) VALUES
(1,'Bodega Costa',3),
(2,'Centro Logístico Norte',1),
(3,'Bodega Central',2);

-- ===========================
-- riwi_categories
-- ===========================

INSERT INTO riwi_categories (category_id,category_name) VALUES
(1,'Consumibles'),
(2,'Elementos de Protección Personal (EPP)'),
(3,'Herramientas');

-- ===========================
-- riwi_products
-- ===========================

INSERT INTO riwi_products (product_id,product_name,category_id) VALUES
(1,'Disco de Corte 4.5',3),
(2,'Electrodo E6013',1),
(3,'Guantes de Nitrilo',2),
(4,'Casco Industrial',2);

-- ===========================
-- riwi_inventory_movements
-- ===========================

INSERT INTO riwi_inventory_movements
(movement_id,movement_date,supplier_id,warehouse_id,product_id,quantity,unit_price,movement_type,purchase_order)
VALUES
(1,'2026-04-01',1,1,1,148,115388,'OUT','PQ-1049'),
(2,'2026-02-14',1,1,2,27,35506,'IN','PQ-1041'),
(3,'2026-01-01',2,1,3,70,14290,'IN','PQ-1022'),
(4,'2026-02-16',1,2,3,160,117524,'IN','PQ-1075'),
(5,'2026-02-28',2,3,2,40,139836,'OUT','PQ-1091'),
(6,'2026-03-06',1,1,1,130,88512,'OUT','PQ-1041'),
(7,'2026-01-20',1,3,2,33,43746,'OUT','PQ-1059'),
(8,'2026-04-13',2,1,3,119,23022,'OUT','PQ-1035'),
(9,'2026-04-17',3,3,3,185,123653,'IN','PQ-1032'),
(10,'2026-02-02',3,3,2,87,123108,'OUT','PQ-1009'),
(11,'2026-05-23',1,1,3,175,39944,'IN','PQ-1040'),
(12,'2026-03-19',1,3,1,199,118291,'OUT','PQ-1023'),
(13,'2026-01-25',2,2,3,131,71980,'OUT','PQ-1029'),
(14,'2026-03-15',1,1,1,134,89964,'OUT','PQ-1035'),
(15,'2026-03-12',2,3,1,124,52910,'IN','PQ-1094'),
(16,'2026-04-26',2,3,1,61,136736,'IN','PQ-1034'),
(17,'2026-03-03',2,2,1,169,18022,'OUT','PQ-1043'),
(18,'2026-03-21',1,1,4,192,108802,'OUT','PQ-1083'),
(19,'2026-03-11',1,2,2,78,37943,'OUT','PQ-1036');

 INSERT INTO riwi_suppliers
(supplier_id, supplier_name, city_id)
VALUES
(5, 'Tecnología Industrial SAS', 2);

INSERT INTO riwi_products
(product_id, product_name, category_id)
VALUES
(6, 'Taladro Industrial Bosch', 3);

UPDATE riwi_suppliers
SET supplier_name = 'Tecnología Industrial Colombia SAS'
WHERE supplier_id = 5;

SELECT *
FROM riwi_suppliers
WHERE supplier_id = 5;

SELECT p.product_id,
       p.product_name
FROM riwi_products p
LEFT JOIN riwi_inventory_movements m
ON p.product_id = m.product_id
WHERE m.product_id IS NULL;
--Stock disponible por producto
SELECT
    p.product_id,
    p.product_name,
    SUM(
        CASE
            WHEN m.movement_type = 'IN' THEN m.quantity
            WHEN m.movement_type = 'OUT' THEN -m.quantity
        END
    ) AS stock_disponible
FROM riwi_products p
JOIN riwi_inventory_movements m
ON p.product_id = m.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY stock_disponible DESC;
--Movimientos de inventario con detalle
SELECT
    m.movement_id,
    m.movement_date,
    p.product_name,
    s.supplier_name,
    w.warehouse_name,
    m.quantity,
    m.unit_price,
    m.movement_type,
    m.purchase_order
FROM riwi_inventory_movements m
JOIN riwi_products p
ON m.product_id = p.product_id
JOIN riwi_suppliers s
ON m.supplier_id = s.supplier_id
JOIN riwi_warehouses w
ON m.warehouse_id = w.warehouse_id
ORDER BY m.movement_date;
--Total comprado por proveedor
    s.supplier_name,
    SUM(m.quantity * m.unit_price) AS total_comprado
FROM riwi_suppliers s
JOIN riwi_inventory_movements m
ON s.supplier_id = m.supplier_id
WHERE m.movement_type = 'IN'
GROUP BY s.supplier_name
ORDER BY total_comprado DESC;
--Cantidad de movimientos por bodega
SELECT
    w.warehouse_name,
    COUNT(m.movement_id) AS total_movimientos
FROM riwi_warehouses w
JOIN riwi_inventory_movements m
ON w.warehouse_id = m.warehouse_id
GROUP BY w.warehouse_name
ORDER BY total_movimientos DESC;
--Producto con mayor volumen de compras
SELECT
    p.product_name,
    SUM(m.quantity) AS total_comprado
FROM riwi_products p
JOIN riwi_inventory_movements m
ON p.product_id = m.product_id
WHERE m.movement_type = 'IN'
GROUP BY p.product_name
ORDER BY total_comprado DESC
LIMIT 1;
--Valor total del inventario por bodega
SELECT
    w.warehouse_name,
    SUM(m.quantity * m.unit_price) AS valor_total_inventario
FROM riwi_warehouses w
JOIN riwi_inventory_movements m
ON w.warehouse_id = m.warehouse_id
GROUP BY w.warehouse_name
ORDER BY valor_total_inventario DESC;
--CREATE VIEW vw_stock_productos AS
SELECT
    p.product_id,
    p.product_name,
    SUM(
        CASE
            WHEN m.movement_type = 'IN' THEN m.quantity
            WHEN m.movement_type = 'OUT' THEN -m.quantity
        END
    ) AS stock_actual
FROM riwi_products p
JOIN riwi_inventory_movements m
ON p.product_id = m.product_id
GROUP BY
    p.product_id,
    p.product_name;

--CREATE VIEW vw_historial_movimientos AS
SELECT
    m.movement_id,
    m.movement_date,
    p.product_name,
    c.category_name,
    s.supplier_name,
    w.warehouse_name,
    m.quantity,
    m.unit_price,
    (m.quantity * m.unit_price) AS total,
    m.movement_type,
    m.purchase_order
FROM riwi_inventory_movements m
JOIN riwi_products p
ON m.product_id = p.product_id
JOIN riwi_categories c
ON p.category_id = c.category_id
JOIN riwi_suppliers s
ON m.supplier_id = s.supplier_id
JOIN riwi_warehouses w
ON m.warehouse_id = w.warehouse_id;
--procedure.sql
CREATE OR REPLACE FUNCTION obtener_proveedores(id_proveedor INT DEFAULT NULL)
RETURNS TABLE (
    supplier_id INT,
    supplier_name VARCHAR,
    city_name VARCHAR
)
LANGUAGE plpgsql
AS
$$
BEGIN

    IF id_proveedor IS NULL THEN

        RETURN QUERY
        SELECT
            s.supplier_id,
            s.supplier_name,
            c.city_name
        FROM riwi_suppliers s
        JOIN riwi_cities c
        ON s.city_id = c.city_id;

    ELSE

        RETURN QUERY
        SELECT
            s.supplier_id,
            s.supplier_name,
            c.city_name
        FROM riwi_suppliers s
        JOIN riwi_cities c
        ON s.city_id = c.city_id
        WHERE s.supplier_id = id_proveedor;

    END IF;

END;
$$;