#In cmd, run py -m pip install pandas
#create olistdashboard_db in database. Refer olist_dashboard_queires.sql


import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

# 1. Create MySQL connection (SAFE method - handles @ in password)
url = URL.create(
    "mysql+pymysql",
    username="yourusername", #mostly root
    password="yourpassword",   
    host="localhost",
    port=3306,
    database="olistdashboard_db"
)

engine = create_engine(url)


# 2. Load CSV file
df = pd.read_csv(r"C:\Users\Desktop\project olist databases\orders.csv") # your csv file path

# 3. Optional cleaning (recommended for dashboards)
df.columns = df.columns.str.lower().str.replace(" ", "_")
df = df.drop_duplicates()

# 4. Push data to MySQL
df.to_sql(
    name="orders",     # table name
    con=engine,
    if_exists="replace",   # replace table if already exists
    index=False
)

print("Data successfully loaded into MySQL!")


