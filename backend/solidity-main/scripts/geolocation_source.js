const api_URL = args[0]; 
const ipfs_CID = args[1]; 
const geolocation = args[2];  
const apiResponse = await Functions.makeHttpRequest({      
  url: `${api_URL}/?ipfs_CID=${ipfs_CID}&geolocation=${geolocation}` 
});  
const { data } = apiResponse.data; return Functions.encodeString(data);