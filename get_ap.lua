print('\nExecute init.lua\n')

cfg = {}
cfg.ssid = 'nodemcu'

wifi.setmode(wifi.SOFTAP)
print('WIFI mode='..wifi.getmode()..')\n')
print('MAC Address: '..wifi.ap.getmac()..'\n')
print('Chip ID: '..node.chipid()..'\n')
print('Heap Size: '..node.heap()..'\n')
wifi.ap.config(cfg)
ip = wifi.ap.getip()
print('IP: '..ip..'\n')

print('\nExecute init.lua\n')
tmr.alarm(0, 3000, 0, function() dofile('main.lua') end)
