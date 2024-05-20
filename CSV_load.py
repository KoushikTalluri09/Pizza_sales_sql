Python Code to export CSV files to Postgresql
_____________________________________________

import pandas as pd
from sqlalchemy import create_engine

conn_st= 'postgresql://postgres:******@localhost/pizza'     # ****** is your password for posthresql conection 
db= create_engine(conn_st)

conn= db.connect()

files= ['order_details','orders','pizza_types','pizzas']

for file in files:
    df=pd.read_csv(f'D:\Pizza Sales\pizza_sales_data\{file}.csv', encoding='unicode_escape')
    df.to_sql(file, con=conn, if_exists='replace', index=False)
