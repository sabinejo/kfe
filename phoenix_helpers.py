
# coding: utf-8

# In[ ]:

# get data 

# global variables
# CC3 = ['KWT', 'BHR', 'OMN', 'QAT', 'SAU', 'ARE', 'YEM', 'ISR', 'PSE', 'JOR', 'LBN', 'SYR',
#        'EGY', 'IRN', 'TUR', 'IRQ']
# CC2 = ['KW', 'BH', 'OM', 'QA', 'SA', 'AE', 'YE', 'IL', 'PS', 'JO', 'LB', 'SY', 'EG', 'IR', 
#        'TR', 'IQ']
# CCS = [690, 692, 698, 694, 670, 696, 680, 666, 'NaN', 663, 660, 652, 651, 630, 640, 645]
# FIPS = ['KU', 'BA', 'MU', 'QA', 'SA', 'AE', 'YM', 'IS', 'NaN', 'JO', 'LE', 'SY', 'EG', 'IR', 
#         'TU', 'IZ']



# country_codes
def namo_cc3():
    CC3 = ["KWT","BHR","OMN","QAT","SAU","ARE","YEM","ISR","PSE","JOR","LBN","SYR","EGY","IRN","TUR","IRQ"]
    return CC3
    
# col names
def get_col_names():
    col_names = ('EventID', 'Date', 'Year', 'Month', 'Day', 'SourceActorFull', 'SourceActorEntity', 
             'SourceActorRole', 'SourceActorAttribute', 'TargetActorFull', 'TargetActorEntity', 
             'TargetActorRole', 'TargetActorAttribute', 'EventCode', 'EventRootCode', 
             'PentaClass', 'GoldsteinScore', 'Issues', 'Lat', 'Lon', 'LocationName', 
             'StateName', 'CountryCode', 'SentenceID', 'URLs', 'NewsSources')

    return col_names


import pandas as pd
###
# create df from csv and filter by country code column
def csv_to_df_CC_filter(filename, country_codes, csv_country_code_column):
    df = pd.read_csv(filename , sep=',')
    return df[df[csv_country_code_column].isin(country_codes)]

# example input and call
# UCDP_filename = '/Users/sabine.a.joseph/Downloads/ged50-csv/ged50.csv'
# country_code_column_name = 'gwno'
# df = csv_to_df_CC_filter(UCDP_filename, CCS, country_code_column_name)

###
# delete not to be used columns
def del_columns_from_df(col_names):
    for i in col_names:
        del df[i]
    return df

# example input and call
#vars_to_del = ['relid', 'year', 'isocc', 'gwab']
#df = del_columns_from_df(vars_to_del)

from datetime import datetime
###
# str date column to datetime index
def str_to_datetime(col_name, dateformat):
    return [datetime.strptime(str(df[col_name][i]), dateformat) 
            for i in range(0, len(df[col_name])) if i is not None]

# example input and call
#df_datestring_column_name = 'date_start'
#dateformat = '%Y-%m-%d'
#df[df_datestring_column_name] = str_to_datetime(df_datestring_column_name, dateformat)

import urllib
import lxml.html
###
# phoenix data: get list of all links off Phoenix website
def connect_to_url_get_links(url):
    connection = urllib.urlopen(url)
    dom =  lxml.html.fromstring(connection.read())

    links = []
    for link in dom.xpath('//a/@href'): # select the url in href for all a tags(links)
        links.append(link) #all download links in list
    del links[0:4] #ugly hack
    return links


import os
import zipfile
###
# phoenix data: unzips all phoenix files and returns list of filenames
# downloads all files in dir #lengthy!!!
def download_and_unzip_files(links,filenames,down_dir = 'phoenix_zip/'):

    if not os.path.exists(down_dir):
        os.makedirs(down_dir)

    # For every line in the file
    for url in links:
        # Split on the rightmost / and take everything on the right side of that
        name = url.rsplit('/', 1)[-1]
        print name.rsplit('.',5)[2]
        # Combine the name and the downloads directory to get the local filename
        filename = os.path.join(down_dir, name)

        # Download the file if it does not exist
        if not os.path.isfile(filename):
            urllib.urlretrieve(url, filename)

    # filenames to unzip 
    for zipfilename in filenames:
            with zipfile.ZipFile(down_dir + zipfilename) as zip_ref:
                zip_ref.extractall(down_dir)

###
# phoenix data: load all data from individual files to df and filter by for country #lengthy!!!
def data_to_df(col_names, country_codes, filter_col, filenames, down_dir = 'phoenix_zip/'):

    txtfilenames = []

    for zipfilename in filenames:
        txtfilenames.append(zipfilename[:-4])

    for i in range(0, len(txtfilenames)):
        if i == 0: #create initial df on first loop iteration
            df = pd.read_table(down_dir + txtfilenames[i], delim_whitespace=False, 
                               names=col_names)
        else: #concatenate df on each iteration
            df = pd.concat([df, pd.read_table(down_dir + txtfilenames[i], delim_whitespace=False, 
                               names = col_names)]) 
            df = df[df[filter_col].isin(country_codes)] 

    df = df[df[filter_col].isin(country_codes)]  
    df = df.reset_index(drop = True)
    return df

# example input and call
# DOWNLOADS_DIR = '/Users/sabine.a.joseph/Documents/sabine.a.joseph/Documents/Phoenix_event_data'
#filenames = download_and_unzip_files(DOWNLOADS_DIR, links)
# links as returned by connect_to_url_get_links function


import numpy as np
###
# aggregate per country / bbox and month
# index needs to be datetime
# enter country_col_name as geo-switch: takes country code or bbox
def agg_by_geo_by_month(df, agg_dict, country_col_name):
    agg_df = df.groupby([df.index, country_col_name]).agg(aggregations)
    agg_df = agg_df.reset_index()
    agg_df.columns = agg_df.columns.get_level_values(0)
    return agg_df

# example input and call
#df['count_num_daily_events'] = 1 

# create aggregates
#aggregations = {
 #   'protest' : {'protest_events': 'sum'},
  #  'material_conflict' : {'material_conflict_events': 'sum'},
   # 'rebellion' : {'rebellion_events': 'sum'},
    #'GoldsteinScale' : {
    #'gs_median': 'median',
    #'gs_min': lambda x: min(x),
    #'gs_max': lambda x: max(x)},
    #'count_num_daily_events' : {'count_num_daily_events': 'sum'}
#}

# geo-level aggregation switch: country vs grid

#agg_df = agg_by_geo_by_month(df, aggregations, 'SourceActorFull') # or 'bbox' for grid level aggregation
#agg_df.rename(columns = {list(agg_df)[4]: 'gs_median', 
 #                        list(agg_df)[5]: 'gs_median', 
  #                       list(agg_df)[6]: 'gs_median'}, inplace = True)


# example input and call
#col_names = ('EventID', 'NewsSources')
#country_code_filter_col_name = 'SourceActorFull'
#df = data_to_df(DOWNLOADS_DIR, col_names, CC3, country_code_filter_col_name)

###
# save df as csv
def df_to_csv(df,filename, path = "phoenix_data/"):

    if not os.path.exists(path):
        os.makedirs(path)

    df.to_csv(path + filename)

# example input and call
# path = '/Users/sabine.a.joseph/Documents/Phoenix_event_data/'
#csv_name = 'Phoenix_NaMo_subset.csv'
#df_to_csv(df, path, csv_name) 

###
# create df from csv
def csv_to_df(path, filename):
    df = pd.read_csv(path + filename, sep = ',', low_memory=False)
    df = df.reset_index(drop=True)
    return df

# example input and call
# path = '/Users/sabine.a.joseph/Documents/Phoenix_event_data/'
#csv_name = 'Phoenix_NaMo_subset.csv'
#df = csv_to_df(path, csv_name)

###
# get and format gridcell data
def correct_coordinate_format(df, colname_list):
    for i in range(0, len(colname_list)):
        df[colname_list[i]] = [(float(df[colname_list[i]][j][:5])) for j in range (0, len(df[colname_list[i]]))]
    return df

# example input and call
#df_grid = pd.read_csv('/Users/sabine.a.joseph/Documents/Gridcells_countrydata.csv', sep = ';')
#df_grid = correct_coordinate_format(df_grid, ['xmin', 'xmax', 'ymin', 'ymax'])

#from rtree import index
import math
###
# get bounding box index column
def rtree_index_to_bbox_column(df_lon_col, df_lat_col):    
    idx = index.Index()
    # create rtree index, contains all bounding boxes
    for i in range(0, len(df_grid.id)):
        # if interleaved is True: xmin, ymin, xmax, ymax
        idx.insert(i, (df_grid.xmin[i], df_grid.ymin[i], df_grid.xmax[i], df_grid.ymax[i]))
    
    # retrieve intersection idx for each coordinate pair
    return [(list(idx.intersection((float(df_lon_col[i]), float(df_lat_col[i]), 
                                    float(df_lon_col[i]), float(df_lat_col[i])))))[0]
            if math.isnan(df_lat_col[i]) is False and (list(idx.intersection((float(df_lon_col[i]), float(df_lat_col[i]), 
                                                                          float(df_lon_col[i]), float(df_lat_col[i])))))
            else np.nan for i in range (0, df.shape[0])]

# example input and call
#df['bbox'] = rtree_index_to_bbox_column(df.longitude, df.latitude)

###
# url and event ID duplicate removal
# create new columns for protest, material conflict, rebellion, radicalism
# cast Goldstein to float
def EoI_columns(df, col_name_dict):
    # max eventid for each url 
    if col_name_dict['url_name'] and col_name_dict['eventID_name'] is not None: 
        gdelt_max_id = df.groupby(col_name_dict['url_name'])[col_name_dict['eventID_name']].max()
        # keep only max ids to remove duplicates
        df = df[df[col_name_dict['eventID_name']].isin(gdelt_max_id)]
        df = df.reset_index()
    if col_name_dict['root_code_name'] is not None: 
        df['protest'] = np.where(df[col_name_dict['root_code_name']]==14, 1, 0)
    if col_name_dict['quad_class_name'] is not None:
        df['material_conflict'] = np.where(df[col_name_dict['quad_class_name']]==int(4), 1, 0)   
    if col_name_dict['actor_name'] is not None: 
        df['rebellion'] = np.where(df[col_name_dict['actor_name']].isin(['REB','SEP','INS']), 1, 0)
    if col_name_dict['Actor1Code'] and col_name_dict['Actor2Code'] and col_name_dict['Actor3Code'] is not None: 
        df['radicalism'] = np.where(np.logical_or.reduce((df[col_name_dict['Actor1Code']]=='RAD',
                                                          df[col_name_dict['Actor2Code']]=='RAD',
                                                          df[col_name_dict['Actor3Code']]=='RAD')),1, 0)
    if 'goldstein_name' in col_name_dict:
        df['GoldsteinScale'] = df[col_name_dict['goldstein_name']].apply(lambda x : float(x))
    return df

# example input and call
# df is event df
# Phoenix column names
#col_names = {
 #   'eventID_name' : 'EventID',
  #  'root_code_name' : 'EventRootCode',
   # 'quad_class_name': 'PentaClass',
    #'geo_country_name' : 'SourceActorFull',
    #'geo_region_name' : 'region',
    #'actor_name' : 'TargetActorRole',
    #'url_name' : 'URLs',
    #'goldstein_name' : 'GoldsteinScore',
    #'date_name' : 'Date',
    #'Actor1Code': None,
    #'Actor2Code': None,
    #'Actor3Code': None
#}

#df = EoI_columns(df, col_names)

###
# aggregate per country / bbox and month
# index needs to be datetime
# enter country_col_name as geo-switch: takes country code or bbox
def agg_by_geo_by_month(df, agg_dict, country_col_name):
    agg_df = df.groupby([df.index, country_col_name]).agg(agg_dict)
    agg_df = agg_df.reset_index()
    agg_df.columns = agg_df.columns.get_level_values(0)
    return agg_df

# example input and call
#df['count_num_daily_events'] = 1 

# create aggregates
#aggregations = {
 #   'protest' : {'protest_events': 'sum'},
  #  'material_conflict' : {'material_conflict': 'sum'},
   # 'rebellion' : {'rebellion_events': 'sum'},
    #'GoldsteinScale' : {
    #'gs_median': 'median',
    #'gs_min': lambda x: min(x),
    #'gs_max': lambda x: max(x)},
    #'AvgTone' : {
    #'at_median': 'median',
    #'at_min': lambda x: min(x),
    #'at_max': lambda x: max(x)},
    #'count_num_daily_events' : {'count_num_daily_events': 'sum'},
    #'NumMentions' : {'NumMentions': 'sum'},
    #'NumSources' : {'NumSources': 'sum'},
    #'NumArticles' : {'NumArticles': 'sum'}
#}

# geo-level aggregation switch: country vs grid

#agg_df = agg_by_geo_by_month(df, aggregations, 'ActionGeo_CountryCode') # or 'bbox' for grid level aggregation
#agg_df.rename(columns = {list(agg_df)[4]: 'gs_median', 
 #                        list(agg_df)[5]: 'gs_min', 
  #                       list(agg_df)[6]: 'gs_max',
   #                      list(agg_df)[7]: 'at_median', 
    #                     list(agg_df)[8]: 'at_min', 
     #                    list(agg_df)[9]: 'at_max',}, inplace = True)

########################################################
###### no longer in use due to performance issue #######
import glob
###
# returns list with all shape files per country 
def filenames_per_country_list(country_code, path):
    folder_name = country_code + '_adm_shp/'
    return glob.glob(path_to_shape + folder_name + '/*.shp')

# example input and call
#path_to_shape = '/Users/sabine.a.joseph/Downloads/' #folders with shapefiles per country
#filenames_per_country = filenames_per_country_list(df.SourceActorFull[0], path_to_shape)


###
# looks up given coordinate in a countries` shapefile and assigns value to region column
def fill_region_column(df, lon, lat, country_code):
    # empty column for region
    df['region']=np.nan
    
    for i in range(0, df.shape[0]):
        filenames_per_country = filenames_per_country_list(country_code[i], path_to_shape)

        # loop through all regions within country (dep. on N shapefiles for each region)
        for k in range(0, len(filenames_per_country)):

            with fiona.open(filenames_per_country[k], 'r') as fiona_collection:
                shapefile_record = next(iter(fiona_collection))
                shape = shapely.geometry.asShape(shapefile_record['geometry'])
                point = shapely.geometry.Point(float(lon[i]),
                                               float(lat[i])) # longitude, latitude

            if shape.contains(point):
                df.loc[i, 'region'] = filenames_per_country[k][-12:-4]

            fiona_collection.close()
    return df

# example input and call
#df = fill_region_column(df, df.Actor1Geo_Long, df.Actor1Geo_Lat, df.Actor1Code)

