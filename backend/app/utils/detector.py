def detect(headers):
    return headers.get("X-App-Client") == 'blind-app'

    