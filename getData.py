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

# inputs
countries = pd.ExcelFile("Input/Country_codes_NAMO.xlsx").parse("Sheet1")
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


def getGdelt(country_codes,date_range_begin,date_range_end,local_path=''):

    # inputs
    gdelt_base_url = 'http://data.gdeltproject.org/events/'

    # # get the list of all the links on the gdelt file page
    # page = requests.get(gdelt_base_url+'index.html')
    # doc = lh.fromstring(page.content)
    # link_list = doc.xpath("//*/ul/li/a/@href")

    # # separate out those links that begin with four digits 
    # file_list = [x for x in link_list if str.isdigit(x[0:4])]

    # print file_list

    # dates
    start = datetime.strptime(date_range_begin, '%Y%m%d')
    end = datetime.strptime(date_range_end, '%Y%m%d') 

    # names of relevant gdelt files to be downloaded
    file_list_selected = []
    for result in dateIncrement(start,end,timedelta(days=1)):
        date_str = result.strftime('%Y%m%d') + '.export.CSV.zip'
        file_list_selected.append(date_str)

    
    infilecounter = 0
    outfilecounter = 0

   # data frame list for selected data
    DFlist = []


    for compressed_file in file_list_selected:
        try:
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


            outfile_name = 'Data/'+'gdelt_'+ date_range_begin + '_' + date_range_end +'.tsv'
            line_counter = 0

            for infile_name in glob.glob(local_path+'tmp/*'):

                print 'event_date is {0}'.format(infile_name[4:12]) ,

                #outfile_name = local_path+'namo_data/'+'extract_'+'%s.tsv'%event_date

                # open the infile and outfile
                with open(infile_name, mode='r') as infile, open(outfile_name, mode='w') as outfile:

                    # keep only root events & countries in 
                    lines_root = [
                        
                        line for line in infile if int(line.split('\t')[25]) == 1 and 
                        line.split('\t')[51] in namo_country_codes

                        ]
                    
                    # save output
                    for line in lines_root:
                        outfile.write(line)
                        line_counter +=1
             
                    # update outfile counter
                    outfilecounter +=1 

                # # append outfile to DFlsit
                # DFlist.append(pd.read_csv(outfile_name, sep='\t', header=None, dtype=str,
                #               names=colnames, index_col=['GLOBALEVENTID']))

                # delete the temporary file infile
                os.remove(infile_name)

            infilecounter +=1
        except BadZipfile:
            continue

    print 'done with processing of {0} files'.format(outfilecounter) 
    #print 'done with downloading of {0} files'.format(outfilecounter) 

    # # Merge the file-based dataframes and save a pickle
    # DF = pd.concat(DFlist)  
    # DF.to_pickle(local_path+'backup'+date_range_begin+'_'+date_range_end + '.pickle')

    # # output as csv
    # file_name = 'gdelt_'+ date_range_begin + '_' + date_range_end +'.csv'
    # DF.to_csv('Data/'+ file_name)

    # # total rows created
    # total_rows = DF.shape[0]
    # print('{0} rows created in {1}').format(total_rows,file_name)


    # remove files downloaded
    downloaded_files = glob.glob('namo_data/' +'extract_'+'*')
    for active_file in downloaded_files:
        os.remove(active_file) 

    DF = pd.read_csv(outfile_name, sep='\t', header=None, dtype=str,
                               names=colnames, index_col=['GLOBALEVENTID'])
    DF.to_csv('Data/'+ file_name)
    file_name = 'gdelt_'+ date_range_begin + '_' + date_range_end +'.csv'

    print('{0} rows created in {1}').format(line_counter,file_name)

# def saveGdelt(colnames,date_range_begin,date_range_end,downloads_path='namo_data/'):
    
#     # dates
#     start = datetime.strptime(date_range_begin, '%Y%m%d')
#     end = datetime.strptime(date_range_end, '%Y%m%d') 

#     # names of relevant gdelt files to be downloaded
#     file_list_selected = []
#     for result in dateIncrement(start,end,timedelta(days=1)):
#         date_str = result.strftime('%Y%m%d') + '.export.CSV.zip'
#         file_list_selected.append(date_str)

#     # Build DataFrames from each of the intermediary files
#     downloaded_files = glob.glob(downloads_path +'extract_'+'*')
    
#     # initialize
#     DFlist = []
    
#     # append files
#     for active_file in downloaded_files:
#         DFlist.append(pd.read_csv(active_file, sep='\t', header=None, dtype=str,
#                                   names=colnames, index_col=['GLOBALEVENTID']))

#     # Merge the file-based dataframes and save a pickle
#     DF = pd.concat(DFlist)
#     #DF.to_pickle(local_path+'backup'+fips_country_code+'.pickle')

#     # output as csv
#     ts = datetime.now().strftime("%Y%m%d")
#     file_name = 'gdelt_{0}.csv'.format(ts)
#     DF.to_csv('Data/'+ file_name)

#     # total rows created
#     total_rows = DF.shape[0]
#     print('{0} rows created in {1}').format(total_rows,file_name)
    


    # # once everythin is safely stored away, remove the temporary files
    # for active_file in downloaded_files:
    #     os.remove(active_file) 


#------------------------------------------------------------------------------------------

getGdelt(country_codes=namo_country_codes,date_range_begin="20160101", date_range_end="20160101")



#getGdelt(country_codes=namo_country_codes,date_range_begin="20140122", date_range_end="20140126")

#saveGdelt(colnames=colnames)

