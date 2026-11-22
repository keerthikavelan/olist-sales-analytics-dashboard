import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

#Create MySQL connection (SAFE method - handles @ in password)
url = URL.create(
    "mysql+pymysql",
    username="yourusername",
    password="yourpassword",   
    host="localhost",
    port=3306,
    database="olistdashboard_db"
)

engine = create_engine(url)

# Folder containing all CSV files
data_path = r"C:\Users\Desktop\project olist databases"

# Dictionary: CSV filename -> MySQL table name
files = {
    "olist_order_items_dataset.csv":"order_items",
    "olist_customers_dataset.csv": "customers",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "product_category_translation"
}

for file_name, table_name in files.items():
    print(f"Loading {table_name}...")

    df = pd.read_csv(f"{data_path}\\{file_name}")

    df.to_sql(
        table_name,
        con=engine,
        if_exists="replace",
        index=False
    )

    print(f"{table_name} loaded successfully.")

print("All datasets loaded successfully!")
