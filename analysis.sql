-- Data Overview -----------------------------
-- Users -----------------------------
-- # total records of users
SELECT COUNT(*) FROM users;

-- # checking null
SELECT COUNT(*) FROM users WHERE user_id IS NULL;
SELECT COUNT(*) FROM users WHERE nama_user IS NULL;
SELECT COUNT(*) FROM users WHERE kodepos IS NULL;
SELECT COUNT(*) FROM users WHERE email IS NULL;

-- Produk -----------------------------
-- # total records of products
SELECT COUNT(*) FROM products;

-- # total records of products category
SELECT COUNT(DISTINCT category) FROM products;

-- # checking null
SELECT COUNT(product_id) FROM products WHERE product_id IS NULL;
SELECT COUNT(desc_product) FROM products WHERE desc_product IS NULL;
SELECT COUNT(category) FROM products WHERE category IS NULL;
SELECT COUNT(base_price) FROM products WHERE base_price IS NULL;

-- Orders -----------------------------
-- # total records of orders
SELECT COUNT(*) FROM orders;

-- # checking null
SELECT COUNT(*) FROM orders WHERE order_id IS NULL;
SELECT COUNT(*) FROM orders WHERE seller_id IS NULL;
SELECT COUNT(*) FROM orders WHERE buyer_id IS NULL;
SELECT COUNT(*) FROM orders WHERE kodepos IS NULL;
SELECT COUNT(*) FROM orders WHERE subtotal IS NULL;
SELECT COUNT(*) FROM orders WHERE discount IS NULL;
SELECT COUNT(*) FROM orders WHERE total IS NULL;
SELECT COUNT(*) FROM orders WHERE created_at IS NULL;
SELECT COUNT(*) FROM orders WHERE paid_at IS NULL;
SELECT COUNT(*) FROM orders WHERE delivery_at IS NULL;

-- Order Details -----------------------------
-- # total records of order details
SELECT COUNT(*) FROM order_details;

-- # checking null
SELECT COUNT(*) FROM order_details WHERE order_detail_id IS NULL;
SELECT COUNT(*) FROM order_details WHERE order_id IS NULL;
SELECT COUNT(*) FROM order_details WHERE product_id IS NULL;
SELECT COUNT(*) FROM order_details WHERE price IS NULL;
SELECT COUNT(*) FROM order_details WHERE quantity IS NULL;


-- Exploratory DQLab Store Analysis -----------------------------
-- Users -----------------------------
-- # counting buyer_id
SELECT COUNT(DISTINCT user_id) 
FROM users
WHERE user_id IN 
	(SELECT DISTINCT(buyer_id)
    FROM orders);

-- # counting seller    
SELECT COUNT(DISTINCT(seller_id))
FROM orders
WHERE seller_id IN
	(SELECT buyer_id
    FROM orders);

-- # counting non buyer non seller
SELECT COUNT(DISTINCT(user_id))
FROM users
WHERE user_id NOT IN
	(SELECT buyer_id
    FROM orders)
AND user_id NOT IN
	(SELECT seller_id
    FROM orders);

-- # counting buyers or sellers who are not in the user list
SELECT seller_id, buyer_id
FROM orders
WHERE seller_id NOT IN 
	(SELECT user_id
    FROM users)
OR buyer_id NOT IN
	(SELECT user_id
    FROM users)
;

-- # counting users by kodepos
SELECT COUNT(DISTINCT(kodepos)) FROM users;

SELECT kodepos, COUNT(DISTINCT(user_id)) number_of_users
FROM users
GROUP BY kodepos
ORDER BY 2 DESC
;


-- Products -----------------------------
-- # counting number of products by product category
SELECT category, COUNT(DISTINCT(product_id)) number_of_products
FROM products
GROUP BY category
ORDER BY 1;


-- Orders -----------------------------
-- # Clasify order status by date
WITH status_orders AS
(SELECT order_id, created_at, paid_at, delivery_at,
CASE
    WHEN paid_at IS NOT NULL and delivery_at IS NOT NULL then 'Selesai'
    WHEN paid_at IS NULL and delivery_at IS NULL then 'Tidak Dibayar'
    WHEN paid_at IS NOT NULL and delivery_at IS NULL then 'Dibayar & Tidak Sampai'
    ELSE 'None'
END AS status_order
FROM orders)

SELECT status_order, COUNT(status_order) number_of_orders
FROM status_orders
GROUP BY 1
;

-- # total transaction each month
SELECT MONTH(created_at) bulan, YEAR(created_at) tahun, COUNT(order_id) total_transaction
FROM orders
WHERE paid_at IS NOT NULL
GROUP BY MONTH(created_at), YEAR(created_at)
ORDER BY 2, 1
;

-- # total sales each month
SELECT MONTH(created_at) bulan, YEAR(created_at) tahun, SUM(total) total_sales
FROM orders
WHERE paid_at IS NOT NULL
GROUP BY MONTH(created_at), YEAR(created_at)
ORDER BY 2, 1
;

-- # total discount
SELECT 
	SUM(discount) total_discount, 
	SUM(total) after_discount, 
	ROUND(((SUM(discount)/(SUM(total)+SUM(discount)))*100),2) discount_percentage_used
FROM orders;


-- DQLab Store Analysis -----------------------------
-- # Top Buyer All The Time
SELECT o.buyer_id, u.nama_user, COUNT(o.order_id) number_of_orders, SUM(o.total) AS total
FROM orders o
INNER JOIN users u 
ON o.buyer_id = u.user_id
WHERE paid_at IS NOT NULL
GROUP BY 1
ORDER BY 4  DESC
LIMIT 5;

-- # Frequent Buyer
SELECT o.buyer_id, u.nama_user, COUNT(o.order_id) order_count, SUM(o.total) total
FROM orders o
INNER JOIN users u
ON buyer_id = user_id
WHERE paid_at IS NOT NULL
GROUP BY 1
HAVING SUM(discount) = 0
ORDER BY 3 DESC, 4 DESC
LIMIT 5;

-- # Big Frequent Buyer
SELECT o1.buyer_id, u.nama_user, u.email, COUNT(DISTINCT(o1.tahun_bulan)) order_count, ROUND(AVG(o1.total)) avg_total
FROM
 (SELECT buyer_id, EXTRACT(YEAR_MONTH FROM created_at) as tahun_bulan, total
 FROM orders
 WHERE YEAR(created_at)= '2020'
 ORDER BY 1, 2) o1
JOIN users u
ON o1.buyer_id = u.user_id
GROUP BY 1
HAVING order_count >=5 AND AVG(o1.total) > 1000000
ORDER BY 4 DESC, 5 DESC
;

-- # Domain email penjual
SELECT DISTINCT(SUBSTRING_INDEX(email, '@', -1)) domain, COUNT(user_id) seller_count
FROM users
WHERE user_id IN
 (SELECT DISTINCT(seller_id)
    FROM orders)
GROUP BY 1
ORDER BY 2 DESC
;

-- # Top 5 Product Des 2019
SELECT p.desc_product, SUM(od.quantity) total_quantity
FROM order_details od
JOIN products p
ON od.product_id = p.product_id
JOIN 
 (SELECT * 
    FROM orders
    WHERE MONTH(created_at) = '12' AND YEAR(created_at) = '2019' AND paid_at IS NOT NULL) o
ON od.order_id = o.order_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- # Pengguna dengan Rata-rata Transaksi Terbesar di Januari 2020
SELECT o.buyer_id, u.nama_user, COUNT(1) AS jumlah_transaksi, ROUND(AVG(o.total), 0) AS avg_nilai_transaksi
FROM orders o
INNER JOIN users u
ON (buyer_id = user_id)
WHERE created_at>='2020-01-01' AND created_at<'2020-02-01'
GROUP BY 1
HAVING COUNT(1)>= 2 
ORDER BY 4 DESC
LIMIT 10;

-- # Transaksi Terbesar pada Desember 2019
SELECT nama_user AS nama_pembeli, total AS nilai_transaksi, created_at AS tanggal_transaksi
FROM orders
INNER JOIN users ON buyer_id = user_id
WHERE created_at>='2019-12-01' AND created_at<'2020-01-01'
AND total >= 20000000
ORDER BY 1;

-- # Kategori Produk Terlaris di 2020
SELECT category, SUM(quantity) AS total_quantity, SUM(price) AS total_price
FROM orders
INNER JOIN order_details USING(order_id)
INNER JOIN products USING(product_id)
WHERE created_at >= '2020-01-01'
AND delivery_at IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- # Pembeli High Value
SELECT nama_user AS nama_pembeli, COUNT(1) AS jumlah_transaksi, SUM(total) AS total_nilai_transaksi, MIN(total) AS min_nilai_transaksi
FROM orders
INNER JOIN users
ON buyer_id = user_id
GROUP BY user_id, nama_user
HAVING COUNT(1) > 5 AND MIN(total) > 2000000
ORDER BY 3 DESC;

-- # Dropshipper
SELECT nama_user AS nama_pembeli, COUNT(1) AS jumlah_transaksi, COUNT(DISTINCT orders.kodepos) AS distinct_kodepos, SUM(total) AS total_nilai_transaksi, AVG(total) AS avg_nilai_transaksi
FROM orders
INNER JOIN users
ON buyer_id = user_id
GROUP BY user_id, nama_user
HAVING COUNT(1) >= 10 AND COUNT(1) = COUNT(DISTINCT orders.kodepos)
ORDER BY 2 DESC;

-- # Reseller Offline
SELECT nama_user AS nama_pembeli, COUNT(1) AS jumlah_transaksi, SUM(total) AS total_nilai_transaksi, AVG(total) AS avg_nilai_transaksi, AVG(total_quantity) AS avg_quantity_per_transaksi
FROM orders
INNER JOIN users
ON buyer_id = user_id
INNER JOIN (
 SELECT order_id, SUM(quantity) AS total_quantity
 FROM order_details
 GROUP BY 1) AS summary_order USING(order_id)
WHERE orders.kodepos = users.kodepos
GROUP BY user_id, nama_user
HAVING COUNT(1) >= 8 AND AVG(total_quantity) > 10
ORDER BY 3 DESC;

-- # Pembeli Sekaligus Penjual
SELECT nama_user AS nama_pengguna, jumlah_transaksi_beli, jumlah_transaksi_jual
FROM users
INNER JOIN (
  SELECT buyer_id, COUNT(1) AS jumlah_transaksi_beli 
  FROM orders
  GROUP BY 1) AS buyer
ON buyer_id = user_id
INNER JOIN (
  SELECT seller_id, COUNT(1) AS jumlah_transaksi_jual
  FROM orders
  GROUP BY 1) AS seller
ON seller_id = user_id
WHERE jumlah_transaksi_beli >= 7
ORDER BY 1;

-- # Lama Transaksi Dibayar
SELECT 
 EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan,
 COUNT(1) AS jumlah_transaksi, 
 AVG(DATEDIFF(paid_at, created_at)) AS avg_lama_dibayar, 
 MIN(DATEDIFF(paid_at, created_at)) min_lama_dibayar, 
 MAX(DATEDIFF(paid_at, created_at)) max_lama_dibayar
FROM orders
WHERE paid_at IS NOT NULL
GROUP BY 1
ORDER BY 1;
