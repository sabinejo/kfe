import requests, json
from wikitools import wiki, api

BASE_URL = "http://en.wikipedia.org/w/api.php"
TITLES = ['Islamic State of Iraq and the Levant', 'Taliban']

for title in TITLES:
    parameters = { 'action': 'query',
             'format': 'json',
             'continue': '',
             'titles': title,
             'prop': 'revisions',
             'rvprop': 'ids|userid',
             'rvlimit': 'max',
             'rvstart':'2016-01-01T12:00:00Z',
             'rvend':'2016-02-28T23:59:00Z',
             'rvdir':'newer'}

    wp_call = requests.get(BASE_URL, params=parameters)
    response = wp_call.json()

    total_revisions = 0

    while True:
      wp_call = requests.get(BASE_URL, params=parameters)
      response = wp_call.json()

      for page_id in response['query']['pages']:
          total_revisions += len(response['query']['pages'][page_id]['revisions'])

      if 'continue' in response:
        parameters['continue'] = response['continue']['continue']
        parameters['rvcontinue'] = response['continue']['rvcontinue']

      else:
        break
 
    print parameters['titles'], total_revisions

