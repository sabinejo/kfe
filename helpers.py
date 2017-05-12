
import arrow
from datetime import datetime, date, timedelta


def dateIncrement(start,end,delta):
    while start <= end:
        yield start
        start +=delta

# names of relevant phoenix files to be downloaded
def getDateList(date_range_begin,date_range_end):

    # dates
    start = datetime.strptime(date_range_begin, '%Y%m%d')
    end = datetime.strptime(date_range_end, '%Y%m%d') 
    
    date_list = []

    # dates
    for result in dateIncrement(start,end,timedelta(days=1)):
        date_list.append(result.strftime('%Y%m%d'))
    
    return date_list


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




