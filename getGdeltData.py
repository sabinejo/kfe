import os
import requests
import lxml.html as lh
import urllib
import zipfile
from zipfile import BadZipfile
import operator
from datetime import datetime, date, timedelta
import pandas as pd
from helpers import dateIncrement,monthChunks,getDateList
from gdelt_helpers import getColNames,namoCountryCodes,unzipAndParse,getOutfileName,concatDF,dfToCsv





#------------------------------------------------------------------------------------------


def getGdeltData(date_range_begin,date_range_end,colnames=getColNames(),country_codes=namoCountryCodes()):


    gdelt_base_url = 'http://data.gdeltproject.org/events/'

    # get strings for the selected time period to be downloaded
    date_strings = []
    for date_string in getDateList(date_range_begin,date_range_end):
        date_strings.append(date_string)

    # get all relevant links to be downloaded and file names to be unzipped

    file_list_selected = []

    for date_string in date_strings:
        date_str = date_string + '.export.CSV.zip'
        file_list_selected.append(date_str)
    
    # create output folder if not present
    output_folder = 'gdelt_tsv_data/'
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # extract
    unzipAndParse(file_list=file_list_selected, gdelt_base_url=gdelt_base_url,country_codes=country_codes,down_dir='gdelt_tsv_data/')

    # get all files to be concatenated
    outfiles = getOutfileName(file_list_selected=file_list_selected, down_dir='gdelt_tsv_data/')

    # concatenate files
    if len(outfiles) > 0:
        DF = concatDF(outfiles=outfiles,colnames=colnames,down_dir='gdelt_tsv_data/')
    else:
        print 'No files selected to process'    

    # save as csv
    outfilename = 'gdelt_'+ date_range_begin + '_' + date_range_end +'.csv'
    dfToCsv(df=DF,outfilename=outfilename, path = "gdelt_data/")    
    
    # total rows created
    total_rows = DF.shape[0]
    print('{0} rows created in {1}').format(total_rows,outfilename)

# # remove files downloaded
    # os.remove(outfile_name) 




# chunk
def getGdelt(date_range_begin,date_range_end,chunking=True):

    print "---------------------------------------------Starting with Gdelt Download---------------------------------------------" 

    if chunking:
        for start,end in monthChunks(start = date_range_begin,end=date_range_end):
            getGdeltData(date_range_begin=start, date_range_end=end)
            print 'downloaded for timeperiod {0} - {1}'.format(start,end)
    else:
        getGdeltData(date_range_begin=date_range_begin, date_range_end=date_range_end)

    print "---------------------------------------------End of Gdelt Download---------------------------------------------" 


