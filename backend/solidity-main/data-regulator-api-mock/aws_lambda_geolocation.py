import json

def lambda_handler(event, context):
    params = event.get('queryStringParameters', {})
    product_url = params.get('ipfs_CID')
    geolocation = params.get('geolocation')

    # Your logic based on the parameters received
    if product_url and geolocation:
        response_data = 'euro'
        return {
            'statusCode': 200,
            'body': json.dumps({'data': response_data})  # Respond with 'data' field
        }
    else:
        error_message = 'Missing parameters'
        return {
            'statusCode': 400,
            'body': json.dumps({'error': error_message})  # Respond with 'error' field
        }
