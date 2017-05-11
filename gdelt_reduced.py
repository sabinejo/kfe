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
from helpers import dateIncrement

# country_codes
namo_country_codes = [
'KU',
'BA',
'MU',
'QA',
'SA',
'AE',
'YM',
'IS',
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


def getGdelt(country_codes,local_path=''):

    # inputs
    gdelt_base_url = 'http://data.gdeltproject.org/events/'

    compressed_file = 'GDELT.MASTERREDUCEDV2.1979-2013.zip'

    infilecounter = 0

   # if we dont have the compressed file stored locally, go get it. Keep trying if necessary.
    while not os.path.isfile(local_path+compressed_file): 
        print 'downloading,',
        urllib.urlretrieve(url=gdelt_base_url+compressed_file, 
                           filename=local_path+compressed_file)
        
    # extract the contents of the compressed file to a temporary directory    
    print 'extracting,',
    z = zipfile.ZipFile(file=local_path+compressed_file, mode='r')    
    z.extractall(path=local_path+'tmp/')

    # parse each of the csv files in the working directory, 
    print 'parsing,',
        
    # create output folder if not present
    output_folder = 'namo_data/'

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    line_counter = 0

    infile_name = 'tmp/' + 'GDELT.MASTERREDUCEDV2.TXT'
    outfile_name = 'namo_data/'+'gdelt_1979-2013' +'.tsv'

    
    # open the infile and outfile
    with open(infile_name, mode='r') as infile, open(outfile_name, mode='w') as outfile:

        # keep only root events & countries in 
        lines_root = [
            
            line for line in infile if int(line.split('\t')[25]) == 1 and 
            line.split('\t')[51] in country_codes

            ]
        
        # save output
        for line in lines_root:
            outfile.write(line)
            line_counter +=1
 

    # delete the temporary file infile
    os.remove(infile_name)

    DF = pd.read_csv(outfile_name, sep='\t', header=None, dtype=str,
                               names=colnames, index_col=False)
    
    file_name = 'gdelt_1979-2013' +'.csv'
    
    DF.to_csv('Data/'+ file_name)

    
getGdelt(country_codes=namo_country_codes)


