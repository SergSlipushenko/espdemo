import serial, requests,json

with serial.Serial('/dev/ttyUSB0') as ser:
    while True:
        rdata=ser.readline()
        print rdata
        data=json.loads(rdata)
        url = (
            'https://api.thingspeak.com/update?'
            'api_key=1X5LYTT917R3US7P&'
            'field1=%s&field2=%.2f&field3=%s' % (data['co2'],data['temp']/100.0,data['hum']))
        print url
        requests.get(url)
