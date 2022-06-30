/*
				"Data untuk Modeling Menggunakan Classification"
	Query dibawah digunakan untuk membuat dataset modeling dengan menggabungkan :
		1. Primary dataset yaitu order_items dan Users 
		2. Secondary dataset yaitu : orders, products, dan distribution_centers
	
	Query menggunakan fungsi Left outer join. Bertujuan untuk menambahkan variabel pendukung dari 
secondary dataset kedalam primary dataset. Variabel yang akan dipergunakan untuk modeling meliputi :
		1. order_items.status
		2. order_items.sale_price
		3. users.age
		4. users.traffic_source
		5. orders.gender
		6. products.category
		7. products.department
		8. distribution_centers.name
	
	Key yang akan digunakan untuk melakukan left outer join meliputi :
		1. order_items.order_id = orders.order_id
		2. order_items.user_id = users.id
		3. order_items.product_id = products.id
		4. products.distribution_center_id = distribution_centers.id
	
	Dikarenakan query akan menggandung empat kali left outer join maka untuk mempermudah penulisan dan
keterbacaan query akan digunakan metode Common Table Expressions (CTEs). Hal tersebut dilakukan dengan
membuat temporary tables berupa tabel hasil left outer join sebelmnya untuk digunakan pada left outer
join selanjutnya.
*/

-- Query Left outer join menggunakan Common Table Expressions
WITH 
	-- Left outer join dataset order_items dan orders 
	-- Nama temporary tables didefinisikan "join_orders"
	join_orders AS (
	SELECT
		order_items.order_id
		, orders.created_at
		, order_items.user_id
		, order_items.product_id
		, order_items.status 
		, order_items.sale_price
		, orders.gender
	FROM 
		order_items	
	LEFT JOIN orders
		ON order_items.order_id = orders.order_id),
	
	-- Left outer join temporary table join_orders dengan tabel users 
	-- Nama temporary tables didefinisikan "join_users"
	join_users AS (
	SELECT
		join_orders.order_id
		, join_orders.created_at
		, join_orders.user_id
		, join_orders.product_id
		, join_orders.status 
		, join_orders.sale_price
		, join_orders.gender
		, users.age
		, users.country
		, users.traffic_source
	FROM 
		join_orders	
	LEFT JOIN users
		ON join_orders.user_id = users.id),
		
	-- Left outer Join dari temporary tables join_users dengan tabel products
	-- Nama temporary tables didefinisikan "join_products"
	join_products AS (
	SELECT
		join_users.order_id
		, join_users.created_at
		, join_users.user_id
		, join_users.product_id
		, join_users.status 
		, join_users.sale_price
		, join_users.gender
		, join_users.age
		, join_users.country
		, join_users.traffic_source
		, products.category
		, products.department
		, products.distribution_center_id
	FROM 
		join_users	
	LEFT JOIN products
		ON join_users.product_id = products.id),
	
	-- Left outer join dari temporary tables join_products dengan tabel distribution_centers
	-- Nama temporary tables didefinisikan "dataset_modeling"
	dataset_modeling AS (
	SELECT
		join_products.order_id
		, join_products.created_at
		, join_products.user_id
		, join_products.product_id
		, join_products.status 
		, join_products.sale_price
		, join_products.gender
		, join_products.age
		, join_products.country
		, join_products.traffic_source
		, join_products.category
		, join_products.department
		, join_products.distribution_center_id
		, distribution_centers.name
	FROM 
		join_products	
	LEFT JOIN distribution_centers
		ON join_products.distribution_center_id = distribution_centers.id)

-- Query untuk menampilkan hasil left outer join pada temporary tables dataset_modeling
SELECT
	DISTINCT order_id --DISTINCT digunakan agar data tidak memiliki duplicate value
	, DATE_TRUNC('day', created_at) AS create_at -- Variabel tanggal transaksi dibuat untuk mengganti status yang irasional
	, status
	, user_id
	, gender
	, age
	, country
	, traffic_source
	, category
	, department
	, sale_price
	, distribution_center_id
FROM 
	dataset_modeling
ORDER BY
	order_id;