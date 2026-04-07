INSERT INTO dim_customer (
    customer_id,
    first_name,
    last_name,
    age,
    email,
    country,
    postal_code,
    pet_type,
    pet_name,
    pet_breed
)
SELECT DISTINCT ON (sale_customer_id)
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM mock_data
WHERE sale_customer_id IS NOT NULL
ORDER BY sale_customer_id, id;

INSERT INTO dim_seller (
    seller_id,
    first_name,
    last_name,
    email,
    country,
    postal_code
)
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
WHERE sale_seller_id IS NOT NULL
ORDER BY sale_seller_id, id;

INSERT INTO dim_product (
    product_id,
    product_name,
    product_category,
    product_price,
    product_quantity,
    pet_category,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date
)
SELECT DISTINCT ON (sale_product_id)
    sale_product_id,
    product_name,
    product_category,
    product_price,
    product_quantity,
    pet_category,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    TO_DATE(product_release_date, 'MM/DD/YYYY'),
    TO_DATE(product_expiry_date, 'MM/DD/YYYY')
FROM mock_data
WHERE sale_product_id IS NOT NULL
ORDER BY sale_product_id, id;

INSERT INTO dim_store (
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data;

INSERT INTO dim_supplier (
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data;

INSERT INTO fact_sales (
    source_id,
    sale_date,
    customer_key,
    seller_key,
    product_key,
    store_key,
    supplier_key,
    sale_quantity,
    sale_total_price
)
SELECT
    m.id,
    TO_DATE(m.sale_date, 'MM/DD/YYYY'),
    dc.customer_key,
    ds.seller_key,
    dp.product_key,
    dst.store_key,
    dsp.supplier_key,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_customer dc
    ON dc.customer_id = m.sale_customer_id
JOIN dim_seller ds
    ON ds.seller_id = m.sale_seller_id
JOIN dim_product dp
    ON dp.product_id = m.sale_product_id
JOIN dim_store dst
    ON dst.store_name IS NOT DISTINCT FROM m.store_name
   AND dst.store_location IS NOT DISTINCT FROM m.store_location
   AND dst.store_city IS NOT DISTINCT FROM m.store_city
   AND dst.store_state IS NOT DISTINCT FROM m.store_state
   AND dst.store_country IS NOT DISTINCT FROM m.store_country
   AND dst.store_phone IS NOT DISTINCT FROM m.store_phone
   AND dst.store_email IS NOT DISTINCT FROM m.store_email
JOIN dim_supplier dsp
    ON dsp.supplier_name IS NOT DISTINCT FROM m.supplier_name
   AND dsp.supplier_contact IS NOT DISTINCT FROM m.supplier_contact
   AND dsp.supplier_email IS NOT DISTINCT FROM m.supplier_email
   AND dsp.supplier_phone IS NOT DISTINCT FROM m.supplier_phone
   AND dsp.supplier_address IS NOT DISTINCT FROM m.supplier_address
   AND dsp.supplier_city IS NOT DISTINCT FROM m.supplier_city
   AND dsp.supplier_country IS NOT DISTINCT FROM m.supplier_country;

SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_seller;
SELECT COUNT(*) FROM dim_product;
SELECT COUNT(*) FROM dim_store;
SELECT COUNT(*) FROM dim_supplier;
SELECT COUNT(*) FROM fact_sales;

SELECT COUNT(DISTINCT sale_customer_id) FROM mock_data;
SELECT COUNT(DISTINCT sale_seller_id) FROM mock_data;
SELECT COUNT(DISTINCT sale_product_id) FROM mock_data;