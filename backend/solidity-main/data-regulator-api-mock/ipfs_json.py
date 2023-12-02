import requests
import json

IPFS_BASE_URI = "https://ipfs.io/ipfs"
test_cid = "QmXt8YW55gJDQJCret3apkrVw2FHMBLSugVqXZCmb32SNr"
class ExtractIPFSData:
    def __init__(self, IPFS_BASE_URI,CID):
        self.IPFS_URI= f'{IPFS_BASE_URI}/{CID}/?filename={CID}'
    
    def query_IPFS(self):
        print(self.IPFS_URI)
        response = requests.get(self.IPFS_URI)
        self.json_data = json.loads(response.json())

