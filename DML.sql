INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM mock_data
    UNION
    SELECT seller_country FROM mock_data
    UNION
    SELECT store_country FROM mock_data
    UNION
    SELECT supplier_country FROM mock_data
) countries
WHERE country_name IS NOT NULL;

INSERT INTO dim_postal_code (postal_code, country_key)
SELECT DISTINCT postal_code, dc.country_key
FROM (
    SELECT customer_postal_code AS postal_code, customer_country AS country_name FROM mock_data
    UNION
    SELECT seller_postal_code, seller_country FROM mock_data
) pc
JOIN dim_country dc
    ON dc.country_name = pc.country_name
WHERE pc.postal_code IS NOT NULL;

INSERT INTO dim_pet_type (pet_type)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type IS NOT NULL;

INSERT INTO dim_pet_breed (pet_breed, pet_type_key)
SELECT DISTINCT m.customer_pet_breed, dpt.pet_type_key
FROM mock_data m
JOIN dim_pet_type dpt
    ON dpt.pet_type = m.customer_pet_type
WHERE m.customer_pet_breed IS NOT NULL;

INSERT INTO dim_product_category (product_category)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL;

INSERT INTO dim_pet_category (pet_category)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL;

INSERT INTO dim_product_brand (product_brand)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL;

INSERT INTO dim_product_material (product_material)
SELECT DISTINCT product_material
FROM mock_data
WHERE product_material IS NOT NULL;

INSERT INTO dim_product_color (product_color)
SELECT DISTINCT product_color
FROM mock_data
WHERE product_color IS NOT NULL;

INSERT INTO dim_product_size (product_size)
SELECT DISTINCT product_size
FROM mock_data
WHERE product_size IS NOT NULL;

INSERT INTO dim_store_location (store_city, store_state, country_key)
SELECT DISTINCT
    m.store_city,
    m.store_state,
    dc.country_key
FROM mock_data m
LEFT JOIN dim_country dc
    ON dc.country_name = m.store_country;

INSERT INTO dim_supplier_location (supplier_city, country_key)
SELECT DISTINCT
    m.supplier_city,
    dc.country_key
FROM mock_data m
LEFT JOIN dim_country dc
    ON dc.country_name = m.supplier_country;

INSERT INTO dim_customer (
    customer_id,
    first_name,
    last_name,
    age,
    email,
    postal_code_key,
    pet_name,
    pet_breed_key
)
SELECT DISTINCT ON (m.sale_customer_id)
    m.sale_customer_id,
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    dpc.postal_code_key,
    m.customer_pet_name,
    dpb.pet_breed_key
FROM mock_data m
LEFT JOIN dim_country dc
    ON dc.country_name = m.customer_country
LEFT JOIN dim_postal_code dpc
    ON dpc.postal_code = m.customer_postal_code
   AND dpc.country_key = dc.country_key
LEFT JOIN dim_pet_type dpt
    ON dpt.pet_type = m.customer_pet_type
LEFT JOIN dim_pet_breed dpb
    ON dpb.pet_breed = m.customer_pet_breed
   AND dpb.pet_type_key = dpt.pet_type_key
WHERE m.sale_customer_id IS NOT NULL
ORDER BY m.sale_customer_id, m.id;

INSERT INTO dim_seller (
    seller_id,
    first_name,
    last_name,
    email,
    postal_code_key
)
SELECT DISTINCT ON (m.sale_seller_id)
    m.sale_seller_id,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    dpc.postal_code_key
FROM mock_data m
LEFT JOIN dim_country dc
    ON dc.country_name = m.seller_country
LEFT JOIN dim_postal_code dpc
    ON dpc.postal_code = m.seller_postal_code
   AND dpc.country_key = dc.country_key
WHERE m.sale_seller_id IS NOT NULL
ORDER BY m.sale_seller_id, m.id;

INSERT INTO dim_product (
    product_id,
    product_name,
    product_category_key,
    product_price,
    product_quantity,
    pet_category_key,
    product_weight,
    product_color_key,
    product_size_key,
    product_brand_key,
    product_material_key,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date
)
SELECT DISTINCT ON (m.sale_product_id)
    m.sale_product_id,
    m.product_name,
    dpc.product_category_key,
    m.product_price,
    m.product_quantity,
    dpetc.pet_category_key,
    m.product_weight,
    dcolor.product_color_key,
    dsize.product_size_key,
    dbrand.product_brand_key,
    dmaterial.product_material_key,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    TO_DATE(m.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(m.product_expiry_date, 'MM/DD/YYYY')
FROM mock_data m
LEFT JOIN dim_product_category dpc
    ON dpc.product_category = m.product_category
LEFT JOIN dim_pet_category dpetc
    ON dpetc.pet_category = m.pet_category
LEFT JOIN dim_product_color dcolor
    ON dcolor.product_color = m.product_color
LEFT JOIN dim_product_size dsize
    ON dsize.product_size = m.product_size
LEFT JOIN dim_product_brand dbrand
    ON dbrand.product_brand = m.product_brand
LEFT JOIN dim_product_material dmaterial
    ON dmaterial.product_material = m.product_material
WHERE m.sale_product_id IS NOT NULL
ORDER BY m.sale_product_id, m.id;

INSERT INTO dim_store (
    store_name,
    store_address,
    store_location_key,
    store_phone,
    store_email
)
SELECT DISTINCT
    m.store_name,
    m.store_location,
    dsl.store_location_key,
    m.store_phone,
    m.store_email
FROM mock_data m
LEFT JOIN dim_country dc
    ON dc.country_name = m.store_country
LEFT JOIN dim_store_location dsl
    ON dsl.store_city IS NOT DISTINCT FROM m.store_city
   AND dsl.store_state IS NOT DISTINCT FROM m.store_state
   AND dsl.country_key IS NOT DISTINCT FROM dc.country_key;

INSERT INTO dim_supplier (
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_location_key
)
SELECT DISTINCT
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    dsl.supplier_location_key
FROM mock_data m
LEFT JOIN dim_country dc
    ON dc.country_name = m.supplier_country
LEFT JOIN dim_supplier_location dsl
    ON dsl.supplier_city IS NOT DISTINCT FROM m.supplier_city
   AND dsl.country_key IS NOT DISTINCT FROM dc.country_key;

INSERT INTO dim_date (
    full_date,
    day,
    month,
    quarter,
    year
)
SELECT DISTINCT
    TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date,
    EXTRACT(DAY FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(MONTH FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(QUARTER FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(YEAR FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER
FROM mock_data
WHERE sale_date IS NOT NULL;

INSERT INTO fact_sales (
    source_id,
    date_key,
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
    dd.date_key,
    dcust.customer_key,
    dseller.seller_key,
    dprod.product_key,
    dstore.store_key,
    dsupplier.supplier_key,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_date dd
    ON dd.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')
JOIN dim_customer dcust
    ON dcust.customer_id = m.sale_customer_id
JOIN dim_seller dseller
    ON dseller.seller_id = m.sale_seller_id
JOIN dim_product dprod
    ON dprod.product_id = m.sale_product_id
LEFT JOIN dim_country store_country
    ON store_country.country_name = m.store_country
LEFT JOIN dim_store_location dsl
    ON dsl.store_city IS NOT DISTINCT FROM m.store_city
   AND dsl.store_state IS NOT DISTINCT FROM m.store_state
   AND dsl.country_key IS NOT DISTINCT FROM store_country.country_key
JOIN dim_store dstore
    ON dstore.store_name IS NOT DISTINCT FROM m.store_name
   AND dstore.store_address IS NOT DISTINCT FROM m.store_location
   AND dstore.store_location_key IS NOT DISTINCT FROM dsl.store_location_key
   AND dstore.store_phone IS NOT DISTINCT FROM m.store_phone
   AND dstore.store_email IS NOT DISTINCT FROM m.store_email
LEFT JOIN dim_country supplier_country
    ON supplier_country.country_name = m.supplier_country
LEFT JOIN dim_supplier_location dspl
    ON dspl.supplier_city IS NOT DISTINCT FROM m.supplier_city
   AND dspl.country_key IS NOT DISTINCT FROM supplier_country.country_key
JOIN dim_supplier dsupplier
    ON dsupplier.supplier_name IS NOT DISTINCT FROM m.supplier_name
   AND dsupplier.supplier_contact IS NOT DISTINCT FROM m.supplier_contact
   AND dsupplier.supplier_email IS NOT DISTINCT FROM m.supplier_email
   AND dsupplier.supplier_phone IS NOT DISTINCT FROM m.supplier_phone
   AND dsupplier.supplier_address IS NOT DISTINCT FROM m.supplier_address
   AND dsupplier.supplier_location_key IS NOT DISTINCT FROM dspl.supplier_location_key;

SELECT 'mock_data' AS table_name, COUNT(*) FROM mock_data
UNION ALL
SELECT 'dim_country', COUNT(*) FROM dim_country
UNION ALL
SELECT 'dim_postal_code', COUNT(*) FROM dim_postal_code
UNION ALL
SELECT 'dim_pet_type', COUNT(*) FROM dim_pet_type
UNION ALL
SELECT 'dim_pet_breed', COUNT(*) FROM dim_pet_breed
UNION ALL
SELECT 'dim_product_category', COUNT(*) FROM dim_product_category
UNION ALL
SELECT 'dim_pet_category', COUNT(*) FROM dim_pet_category
UNION ALL
SELECT 'dim_product_brand', COUNT(*) FROM dim_product_brand
UNION ALL
SELECT 'dim_product_material', COUNT(*) FROM dim_product_material
UNION ALL
SELECT 'dim_product_color', COUNT(*) FROM dim_product_color
UNION ALL
SELECT 'dim_product_size', COUNT(*) FROM dim_product_size
UNION ALL
SELECT 'dim_store_location', COUNT(*) FROM dim_store_location
UNION ALL
SELECT 'dim_supplier_location', COUNT(*) FROM dim_supplier_location
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;