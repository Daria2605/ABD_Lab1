DROP TABLE IF EXISTS fact_sales CASCADE;

DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

DROP TABLE IF EXISTS dim_postal_code CASCADE;
DROP TABLE IF EXISTS dim_country CASCADE;

DROP TABLE IF EXISTS dim_pet_breed CASCADE;
DROP TABLE IF EXISTS dim_pet_type CASCADE;

DROP TABLE IF EXISTS dim_product_category CASCADE;
DROP TABLE IF EXISTS dim_pet_category CASCADE;
DROP TABLE IF EXISTS dim_product_brand CASCADE;
DROP TABLE IF EXISTS dim_product_material CASCADE;
DROP TABLE IF EXISTS dim_product_color CASCADE;
DROP TABLE IF EXISTS dim_product_size CASCADE;

DROP TABLE IF EXISTS dim_store_location CASCADE;
DROP TABLE IF EXISTS dim_supplier_location CASCADE;

CREATE TABLE dim_country (
    country_key SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_postal_code (
    postal_code_key SERIAL PRIMARY KEY,
    postal_code VARCHAR(50) NOT NULL,
    country_key INTEGER REFERENCES dim_country(country_key),
    UNIQUE (postal_code, country_key)
);

CREATE TABLE dim_pet_type (
    pet_type_key SERIAL PRIMARY KEY,
    pet_type VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_pet_breed (
    pet_breed_key SERIAL PRIMARY KEY,
    pet_breed VARCHAR(100) NOT NULL,
    pet_type_key INTEGER REFERENCES dim_pet_type(pet_type_key),
    UNIQUE (pet_breed, pet_type_key)
);

CREATE TABLE dim_product_category (
    product_category_key SERIAL PRIMARY KEY,
    product_category VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_pet_category (
    pet_category_key SERIAL PRIMARY KEY,
    pet_category VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_product_brand (
    product_brand_key SERIAL PRIMARY KEY,
    product_brand VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_product_material (
    product_material_key SERIAL PRIMARY KEY,
    product_material VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_product_color (
    product_color_key SERIAL PRIMARY KEY,
    product_color VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_product_size (
    product_size_key SERIAL PRIMARY KEY,
    product_size VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_store_location (
    store_location_key SERIAL PRIMARY KEY,
    store_city VARCHAR(100),
    store_state VARCHAR(100),
    country_key INTEGER REFERENCES dim_country(country_key),
    UNIQUE (store_city, store_state, country_key)
);

CREATE TABLE dim_supplier_location (
    supplier_location_key SERIAL PRIMARY KEY,
    supplier_city VARCHAR(100),
    country_key INTEGER REFERENCES dim_country(country_key),
    UNIQUE (supplier_city, country_key)
);

CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(255),
    postal_code_key INTEGER REFERENCES dim_postal_code(postal_code_key),
    pet_name VARCHAR(100),
    pet_breed_key INTEGER REFERENCES dim_pet_breed(pet_breed_key)
);

CREATE TABLE dim_seller (
    seller_key SERIAL PRIMARY KEY,
    seller_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    postal_code_key INTEGER REFERENCES dim_postal_code(postal_code_key)
);

CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    product_name VARCHAR(255),
    product_category_key INTEGER REFERENCES dim_product_category(product_category_key),
    product_price NUMERIC(10,2),
    product_quantity INTEGER,
    pet_category_key INTEGER REFERENCES dim_pet_category(pet_category_key),
    product_weight NUMERIC(10,2),
    product_color_key INTEGER REFERENCES dim_product_color(product_color_key),
    product_size_key INTEGER REFERENCES dim_product_size(product_size_key),
    product_brand_key INTEGER REFERENCES dim_product_brand(product_brand_key),
    product_material_key INTEGER REFERENCES dim_product_material(product_material_key),
    product_description TEXT,
    product_rating NUMERIC(3,1),
    product_reviews INTEGER,
    product_release_date DATE,
    product_expiry_date DATE
);

CREATE TABLE dim_store (
    store_key SERIAL PRIMARY KEY,
    store_name VARCHAR(255),
    store_address VARCHAR(255),
    store_location_key INTEGER REFERENCES dim_store_location(store_location_key),
    store_phone VARCHAR(50),
    store_email VARCHAR(255),
    UNIQUE (store_name, store_address, store_location_key, store_phone, store_email)
);

CREATE TABLE dim_supplier (
    supplier_key SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255),
    supplier_contact VARCHAR(255),
    supplier_email VARCHAR(255),
    supplier_phone VARCHAR(50),
    supplier_address VARCHAR(255),
    supplier_location_key INTEGER REFERENCES dim_supplier_location(supplier_location_key),
    UNIQUE (
        supplier_name,
        supplier_contact,
        supplier_email,
        supplier_phone,
        supplier_address,
        supplier_location_key
    )
);

CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INTEGER,
    month INTEGER,
    quarter INTEGER,
    year INTEGER
);

CREATE TABLE fact_sales (
    sales_key SERIAL PRIMARY KEY,
    source_id INTEGER NOT NULL,
    date_key INTEGER REFERENCES dim_date(date_key),
    customer_key INTEGER REFERENCES dim_customer(customer_key),
    seller_key INTEGER REFERENCES dim_seller(seller_key),
    product_key INTEGER REFERENCES dim_product(product_key),
    store_key INTEGER REFERENCES dim_store(store_key),
    supplier_key INTEGER REFERENCES dim_supplier(supplier_key),
    sale_quantity INTEGER,
    sale_total_price NUMERIC(10,2)
);