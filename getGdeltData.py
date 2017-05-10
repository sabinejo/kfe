import requests
import lxml.html as lh
import os
import urllib
import zipfile
from zipfile import BadZipfile
import operator
import glob
import pandas as pd
from datetime import datetime, date, timedelta
from helpers import dateIncrement,monthChunks,get_zip


# inputs
countries = pd.ExcelFile("Input/Country_codes_NAMO.xlsx").parse("Sheet1")
# country_codes
namo_country_codes = ['IS',

'KU',
'BA',
'MU',
'QA',
'SA',
'AE',
'YM',
'JO',
'LE',
'SY',
'EG',
'IR',
'TU',
'IZ'
]

# GDELT field names from a helper file
colnames = pd.read_excel('Input/CSV.header.fieldids.xlsx', sheetname='Sheet1', 
                             index_col='Column ID', parse_cols=1)['Field Name']

#------------------------------------------------------------------------------------------


def getGdelt(country_codes,date_range_begin,date_range_end,colnames=colnames):

    # inputs
    gdelt_base_url = 'http://data.gdeltproject.org/events/'

    # dates
    start = datetime.strptime(date_range_begin, '%Y%m%d')
    end = datetime.strptime(date_range_end, '%Y%m%d') 

    # names of relevant gdelt files to be downloaded

    file_list_selected = []

    for result in dateIncrement(start,end,timedelta(days=1)):
        date_str = result.strftime('%Y%m%d') + '.export.CSV.zip'
        file_list_selected.append(date_str)

    
    outfilecounter = 0

    
    # create output folder if not present
    output_folder = 'namo_data/'
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    line_counter = 0

    for compressed_file in file_list_selected:
        
        # downloading the zipped file 
        print 'retrieving {0},'.format(compressed_file[0:8]),
        
        file_url = gdelt_base_url+compressed_file
        
        print 'extracting,',

        # if file doesnt exist

        try:
            extracted_file = get_zip(file_url)
        except BadZipfile:
            continue
        
        # parse each of the csv files in the working directory, 
        print 'parsing,',
            

        outfile_name = 'namo_data/'+'gdelt_'+ compressed_file[0:8] +'.tsv'

        # check if its already there
        while not os.path.isfile(outfile_name):

            with open(outfile_name, mode='w') as outfile:

                # keep only root events & countries in namo list
                lines = [
                           line for line in extracted_file.readlines() if int(line.split('\t')[25]) == 1 and line.split('\t')[51] in namo_country_codes
                        ]
                
                # save output
                for line in lines:
                    outfile.write(line)
                    line_counter +=1

         
                # update outfile counter
                print 'written lines: {0}'.format(len(lines))
                outfilecounter +=1 


    print 'done with processing of {0} files'.format(outfilecounter) 


    # read output created and add headers
    processed_files = [file[10:] for file in glob.glob('namo_data/*')]
    selected_files  = ['gdelt_' + file[0:8] + '.tsv' for file in file_list_selected]

    outfiles = [file for file in processed_files if file in selected_files]

    DFlist = []

    for active_file in outfiles:
        DFlist.append(pd.read_csv('namo_data/'+ active_file, sep='\t', header=None, dtype=str,
                                  names=colnames, index_col=['GLOBALEVENTID']))

    # Merge the file-based dataframes and save a pickle
    DF = pd.concat(DFlist)
    # save as csv
    file_name = 'gdelt_'+ date_range_begin + '_' + date_range_end +'.csv'
    DF.to_csv('Data/'+ file_name)
    # total rows created
    total_rows = DF.shape[0]
    print('{0} rows created in {1}').format(total_rows,file_name)

    # # remove files downloaded
    # os.remove(outfile_name) 


#------------------------------------------------------------------------------------------

# monthly download

for start,end in monthChunks(start = "20151101",end="20151231"):
    getGdelt(country_codes=namo_country_codes,date_range_begin=start, date_range_end=end, colnames=colnames)
    print 'downloaded for timeperiod {0} - {1}'.format(start,end)
