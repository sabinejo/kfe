import urllib
import lxml.html
import pandas as pd
import os
import zipfile
import numpy as np
from datetime import datetime,date, timedelta
import glob
#from rtree import index
from phoenix_helpers import namo_cc3,get_col_names, connect_to_url_get_links, download_and_unzip_files, data_to_df, df_to_csv, csv_to_df
from helpers import dateIncrement,getDateList


def getPhoenix(date_range_begin,date_range_end,country_codes=namo_cc3(),col_names=get_col_names()):
    
    print "---------------------------------------------Starting with Phoenix Download---------------------------------------------" 
    # url
    url = 'http://phoenixdata.org/data'

    # get strings for the selected time period to be downloaded
    date_strings = []
    for date_string in getDateList(date_range_begin,date_range_end):
        date_strings.append(date_string)

    # downloads & unzip

    # get all relevant links to be downloaded and file names to be unzipped
    file_list_selected = []
    filenames = []

    for date_string in date_strings:
        file_list_selected.append('https://s3.amazonaws.com/oeda/data/current/events.full.'+ date_string + '.txt.zip')
        filenames.append('events.full.'+ date_string + '.txt.zip')
                                                                                                                                                                                                                                                                                                                                                                                                         
    download_and_unzip_files(links=file_list_selected, filenames = filenames)


    country_code_filter_col_name = 'SourceActorFull'


    df = data_to_df(col_names=col_names, country_codes=country_codes, filter_col=country_code_filter_col_name,filenames=filenames,down_dir = 'phoenix_zip/')

    # save df as csv
    csv_name = 'phoenix_' + date_range_begin + '_' + date_range_end +'.csv'
       
    df_to_csv(df=df, filename= csv_name)   

    print "---------------------------------------------End of Phoenix Download---------------------------------------------"



#getPhoenix(date_range_begin='20140620', date_range_end='20140622')