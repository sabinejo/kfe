
import arrow
import requests
import zipfile
from zipfile import BadZipfile
from datetime import datetime, date, timedelta
from StringIO import StringIO


def dateIncrement(start,end,delta):
    while start <= end:
        yield start
        start +=delta

def get_zip(file_url):
    url = requests.get(file_url)
    zipped_file = zipfile.ZipFile(StringIO(url.content))
    zip_names = zipped_file.namelist()
    if len(zip_names) == 1:
        file_name = zip_names.pop()
        extracted_file = zipped_file.open(file_name)
        return extracted_file

def monthChunks(start,end):
	start_date = arrow.get(datetime.strptime(start, '%Y%m%d'))
	end_date = arrow.get(datetime.strptime(end, '%Y%m%d'))

	# date format
	while start_date < end_date:
		start_mnth = start_date.floor('month')
		end_mnth = start_mnth.ceil('month')
		if end_date < end_mnth:
			yield [start_mnth.format('YYYYMMDD'),end_date.format('YYYYMMDD')]
		else:
			yield [start_mnth.format('YYYYMMDD'),end_mnth.format('YYYYMMDD')]
		start_date = end_mnth.replace(days=1)




