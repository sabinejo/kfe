import requests
import lxml.html as lh
import os
import urllib
import zipfile
import operator
import glob
import pandas as pd
from datetime import datetime 


# inputs
countries = pd.ExcelFile("Input/Country_codes_NAMO.xlsx").parse("Sheet1")
# country_codes
namo_country_codes = list(countries.Country_2)

# GDELT field names from a helper file
colnames = pd.read_excel('Input/CSV.header.fieldids.xlsx', sheetname='Sheet1', 
                             index_col='Column ID', parse_cols=1)['Field Name']


#------------------------------------------------------------------------------------------

   
def getGdelt(country_codes, days_in_past, local_path =''):

    # inputs
    gdelt_base_url = 'http://data.gdeltproject.org/events/'

    # get the list of all the links on the gdelt file page
    page = requests.get(gdelt_base_url+'index.html')
    doc = lh.fromstring(page.content)
    link_list = doc.xpath("//*/ul/li/a/@href")

    # separate out those links that begin with four digits 
    file_list = [x for x in link_list if str.isdigit(x[0:4])]

    
    infilecounter = 0
    outfilecounter = 0

    
    for compressed_file in file_list[:days_in_past]:
        print compressed_file,
    
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

        for infile_name in glob.glob(local_path+'tmp/*'):
            event_date = infile_name[4:12]
            print event_date
            outfile_name = local_path+'namo_data/'+'extract_'+'%s.tsv'%event_date

            # open the infile and outfile
            with open(infile_name, mode='r') as infile, open(outfile_name, mode='w') as outfile:
                records = 0
                for line in infile:
                    # extract lines with our interest country code
                    #based on columns: ActionGeo_ADM1Code 51, Actor1Geo_ADM1Code 37, Actor2Geo_ADM1Code 44
                    la = [country for country in country_codes if country in set(operator.itemgetter(51, 37, 44)(line.split('\t')))]
                    if la:
                        outfile.write(line)
                        records +=1
                print '{0} record in {1}'.format(records,outfile_name)                
                outfilecounter +=1

                    
            # delete the temporary file
            os.remove(infile_name)
        infilecounter +=1

        print 'outfilecounter is %s'%outfilecounter
        print 'infilecounter is %s'%infilecounter

    print 'done'
    

def saveGdelt(colnames,downloads_path='namo_data/'):
    
    # Build DataFrames from each of the intermediary files
    downloaded_files = glob.glob(downloads_path +'extract_'+'*')
    
    # initialize
    DFlist = []
    
    # append files
    for active_file in downloaded_files:
        DFlist.append(pd.read_csv(active_file, sep='\t', header=None, dtype=str,
                                  names=colnames, index_col=['GLOBALEVENTID']))

    # Merge the file-based dataframes and save a pickle
    DF = pd.concat(DFlist)
    #DF.to_pickle(local_path+'backup'+fips_country_code+'.pickle')

    # output as csv
    ts = datetime.now().strftime("%Y%m%d")
    file_name = 'gdelt_{0}.csv'.format(ts)
    DF.to_csv('Data/'+ file_name)

    # total rows created
    total_rows = DF.shape[0]
    print total_rows
    print('{0} rows created in {1}').format(total_rows,file_name)
    


    # # once everythin is safely stored away, remove the temporary files
    # for active_file in downloaded_files:
    #     os.remove(active_file) 


#------------------------------------------------------------------------------------------

#getGdelt(country_codes=namo_country_codes, days_in_past=3)

saveGdelt(colnames=colnames)
 