import requests
import urllib
import json

#Connect to Atlas
client_id = 'XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX'
client_secret = 'XXXXXXXXXXXXXXXXXXXXXXXX' 
Region = "XXXXXXXX"

#Format URL
baseurl  = Region+".snowsoftware.io/idp/api/connect/token?"
url = "https://"+Region+".snowsoftware.io/idp/api/connect/token"
params = {'grant_type': 'client_credentials', 'client_id': client_id, 'client_secret': client_secret}
fullUri = url + urllib.parse.urlencode(params)

#Get_Token
headers = {'Content-Type': 'application/x-www-form-urlencoded'}
data = requests.post(url, params, headers)
jsondata = data.content
content = json.loads(jsondata)
token = content['access_token']
print(token)