import requests
import json
from bs4 import BeautifulSoup
from xml.etree import ElementTree


url = 'http://www.electionguide.org/elections/past'
#url = 'http://www.electionguide.org/elections/?inst=&cont=Bahrain&yr'

response = requests.get(url)


soup = BeautifulSoup(response.content, "html.parser")




#empty list 
data = []

table = soup.find("table", { "class" : "table table-striped"  })
table_body = table.find('tbody')

rows = table_body.find_all('tr')

for row in rows:
    cols = row.find_all('td')
    cols = [ele.text.strip() for ele in cols[1:]] # ignore the col with the flag
    data.append([ele for ele in cols if ele])

print data


