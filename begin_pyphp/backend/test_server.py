import requests
import time

# Wait for server to be ready
time.sleep(2)

try:
    response = requests.get('http://127.0.0.1:8000/health', timeout=5)
    print('✅ Server is running!')
    print('Status:', response.status_code)
    print('Response:', response.json())
    
    # Test login
    login_data = {'email': 'manager@masimba.farm', 'password': 'manager123'}
    response = requests.post('http://127.0.0.1:8000/api/auth/login', json=login_data, timeout=5)
    print('\n🔑 Login Test:')
    print('Status:', response.status_code)
    print('Response:', response.json())
    
except Exception as e:
    print('❌ Error:', e)
