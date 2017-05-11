
import urllib
import lxml.html
import pandas as pd
import os
import zipfile
import numpy as np
from datetime import datetime
from helpers import connect_to_url_get_links, download_and_unzip_files, data_to_df, df_to_csv, csv_to_df

# country codes 
CC3 = ["KWT","BHR","OMN","QAT","SAU","ARE","YEM","ISR","PSE","JOR","LBN","SYR","EGY","IRN","TUR","IRQ"]
# url
url = 'http://phoenixdata.org/data'

# get all links
links = connect_to_url_get_links(url)

# downloads & unzip
                                                                                                                                                                                                                                                                                                                                                                                                                            
download_and_unzip_files(DOWNLOADS_DIR, links)

# load all data to df, for relevant region #lengthy!!!
col_names = ('EventID', 'Date', 'Year', 'Month', 'Day', 'SourceActorFull', 'SourceActorEntity', 
             'SourceActorRole', 'SourceActorAttribute', 'TargetActorFull', 'TargetActorEntity', 
             'TargetActorRole', 'TargetActorAttribute', 'EventCode', 'EventRootCode', 
             'PentaClass', 'GoldsteinScore', 'Issues', 'Lat', 'Lon', 'LocationName', 
             'StateName', 'CountryCode', 'SentenceID', 'URLs', 'NewsSources')

country_code_filter_col_name = 'SourceActorFull'


df = data_to_df(DOWNLOADS_DIR, col_names, CC3, country_code_filter_col_name)

# save df as csv
csv_name = 'Phoenix_NaMo_subset.csv'
   
df_to_csv(path, csv_name)   

#### if all already downloaded (previous steps), use the csv

df = csv_to_df(path, csv_name)


# # In[13]:

# # delete not to be used columns
# # 'id' # only keep for data cleaning 
# vars_to_del = ['EventID', 'Year', 'Month', 'Day', 'SourceActorEntity',
#            'SourceActorRole', 'SourceActorAttribute', 'TargetActorEntity', 'TargetActorRole', 
#            'TargetActorAttribute', 'Issues', 'Lat', 'Lon', 'LocationName', 'StateName', 'CountryCode',
#            'SentenceID', 'URLs']
  
# def del_columns_from_df(col_names):
#     for i in col_names:
#         del df[i]
#     return df

# df = del_columns_from_df(vars_to_del)


# In[14]:

df = df.reset_index(drop=True)
df.Date = [str(df.Date[i])[:-2] for i in range (0, len(df.Date)) if i is not None]

df_datestring_column_name = 'Date'
dateformat = '%Y%m%d'

def str_to_datetime(col_name, dateformat):
    return [datetime.strptime(str(df[col_name][i]), dateformat) 
            for i in range(0, len(df[col_name])) if i is not None]

df[df_datestring_column_name] = str_to_datetime(df_datestring_column_name, dateformat)


# In[ ]:

# filter type of crisis 
# TargetActorFull # 1: state-based conflict # 2: non-state conflict # 3: one-sided violence
df = df[df['PentaClass'].isin([1, 4])]

# TargetActorEntity
# EventCode
# EventRootCode
# NewsSources #sum individual newspapers 1 or two or more, count semicolons


# In[68]:

# grouping by date per country code
new_format = '%Y-%m-%d'
col_name_date = 'Date'
col_name_country_codes = 'SourceActorFull'
agg_col_names = ['GoldsteinScore']
event_count_col_name = 'count_num_daily_events'

def group_by_country_code_date_agg_sum(date, CC, col_name_list, ct_col_name, funct):
# sum of death counts
# count of events per day per country code
    df[ct_col_name] = 1 
    col_name_list.append(ct_col_name)
    return df.groupby([date, CC]).agg(dict.fromkeys(col_name_list, funct))
    # np.nanmedian
    
df_agg = group_by_country_code_date_agg_sum(col_name_date, col_name_country_codes, agg_col_names, event_count_col_name, sum).reset_index()
df_agg.date_start = [df_agg[col_name_date][i].strftime(new_format) for i in range(0, len(df_agg.index)) if i is not None]

df_agg_GS = group_by_country_code_date_agg_sum(col_name_date, col_name_country_codes, agg_col_names, event_count_col_name, np.nanmedian).reset_index()
df_agg.GoldsteinScore = df_agg_GS.GoldsteinScore


# In[70]:

csv_name = 'Phoenix_NaMo_Agg_subset.csv'
df_agg.to_csv(path + csv_name)


# In[109]:

# add column: event 0 - 1
# relations between columns

#df['TargetActorRole2'] = pd.factorize(df['TargetActorRole'])[0]
#df['SourceActorFull2'] = pd.factorize(df['SourceActorFull'])[0]

#df[['EventCode','EventRootCode']] = df[['EventCode','EventRootCode']].apply(pd.to_numeric, errors='ignore')

