import json
import logging
import os
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    '''
    Main Lambda orchestrator handler for API Gateway requests
    '''
    try:
        # Log the incoming request
        logger.info(f'Received event: {json.dumps(event)}')
        
        # Extract basic request info
        http_method = event.get('httpMethod', 'UNKNOWN')
        path = event.get('path', '/')
        
        # Basic routing
        if path == '/health':
            return create_response(200, {'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})
        elif path == '/info':
            return create_response(200, {
                'service': 'aws-ai-platform',
                'version': '1.0.0',
                'environment': os.environ.get('ENVIRONMENT', 'dev'),
                'tables': {
                    'events': os.environ.get('EVENTS_TABLE'),
                    'sessions': os.environ.get('SESSIONS_TABLE'), 
                    'dashboard': os.environ.get('DASHBOARD_TABLE')
                }
            })
        else:
            return create_response(404, {'error': 'Not found', 'path': path})
            
    except Exception as e:
        logger.error(f'Error processing request: {str(e)}')
        return create_response(500, {'error': 'Internal server error'})

def create_response(status_code: int, body: dict) -> dict:
    '''
    Create a properly formatted API Gateway response
    '''
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        },
        'body': json.dumps(body)
    }
