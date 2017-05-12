import os
import requests
import zipfile
from zipfile import BadZipfile
from StringIO import StringIO
import pandas as pd
import glob
import urllib


# GDELT field names from a helper file
def getColNames():
    colnames = pd.read_excel('Input/CSV.header.fieldids.xlsx', sheetname='Sheet1', 
                             index_col='Column ID', parse_cols=1)['Field Name']
    return colnames

# country_codes
def namoCountryCodes():
    namo_country_codes = ['IS','KU','BA','MU','QA','SA','AE','YM','JO','LE','SY','EG','IR','TU','IZ']
    return namo_country_codes

def getZip(file_url):
    url = requests.get(file_url)
    zipped_file = zipfile.ZipFile(StringIO(url.content))
    zip_names = zipped_file.namelist()
    if len(zip_names) == 1:
        file_name = zip_names.pop()
        extracted_file = zipped_file.open(file_name)
        return extracted_file

def unzipAndParse(file_list, gdelt_base_url,country_codes,down_dir='gdelt_tsv_data/'):

    outfilecounter = 0

    for compressed_file in file_list:
        
        # downloading the zipped file 
        
        file_url = gdelt_base_url+compressed_file
        
        # catch if file doesnt exist

        print 'retrieving {0},'.format(compressed_file[0:8]),

        outfile_name = down_dir +'gdelt_'+ compressed_file[0:8] +'.tsv'

        # check if its already there
        while not os.path.isfile(outfile_name):
            try:
                extracted_file = getZip(file_url)
            except BadZipfile:
                continue
                

            # parse each of the csv files in the working directory, 
            print 'parsing,',

            with open(outfile_name, mode='w') as outfile:

                # keep only root events & countries in namo list
                lines = [
                           line for line in extracted_file.readlines() if int(line.split('\t')[25]) == 1 and line.split('\t')[51] in country_codes
                        ]
                
                # save output
                for line in lines:
                    outfile.write(line)

         
                # update outfile counter
                print 'written lines: {0}'.format(len(lines))
                outfilecounter +=1 

    print 'done with processing of {0} files'.format(outfilecounter) 


def getOutfileName(file_list_selected, down_dir='gdelt_tsv_data/'):
    # read output created and add headers

    # all processed files
    processed_files = [file[15:] for file in glob.glob(down_dir + '*')]
    # files selected for download in this iteration
    selected_files  = ['gdelt_' + file[0:8] + '.tsv' for file in file_list_selected]

    # get file names from processed file which were selected
    outfiles = [file for file in processed_files if file in selected_files]    

    return outfiles


def concatDF(outfiles,colnames,down_dir='gdelt_tsv_data/'):
        
        DFlist = []

        for active_file in outfiles:
            DFlist.append(pd.read_csv(down_dir + active_file, sep="\t",header=None, dtype=str,
                                      names=colnames, index_col=False))

        # Merge the file-based dataframes and save a pickle
        DF = pd.concat(DFlist)
        return DF

def dfToCsv(df,outfilename, path = "gdelt_data/"):

    if not os.path.exists(path):
        os.makedirs(path)

    df.to_csv(path + outfilename)