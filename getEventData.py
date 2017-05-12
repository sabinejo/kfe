
from getGdeltData import getGdelt
from getPhoenixData import getPhoenix

#date_range_begin = '20140101'
#date_range_end = '20170430'


date_range_begin = '20140701'
date_range_end = '20140702'


getPhoenix(date_range_begin=date_range_begin, date_range_end=date_range_end)

getGdelt(date_range_begin=date_range_begin, date_range_end=date_range_end, chunking = True)


