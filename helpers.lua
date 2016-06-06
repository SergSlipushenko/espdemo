function wifi_connect(when_connected)
    wifi.setmode(wifi.STATION)
    wifi.sta.config("Skynet","NOlanNOfun")
    wifi.sta.setip({ip="192.168.0.77",netmask="255.255.0.0", gateway="192.168.0.1"})
    wifi.sta.connect()
    print('Wait for connection\n')
    tmr.alarm(0, 7000, tmr.ALARM_SINGLE, function() 
        if wifi.sta.status() == 5 then
            print('Success!')
            local ip = wifi.sta.getip()
            print('IP: '..ip..'\n')
            if when_connected then when_connected() end
        else print('Failure\n') end
    end)
end

function run_web_server()
    srv = net.createServer(net.TCP)
    srv:listen(80,function(conn)
        conn:on('receive',function(conn,payload)
            ok, temp, hum = dht.read(4)
            if ok == 0 then
                conn:send('<h3>Temperature:'..temp..' Humidity: '..hum..'</h3>')
            else
                conn:send('<h3>Something went wrong</h3>')
            end
         end)
         conn:on("sent",function(conn) conn:close() end)
     end)
     print('Simple web server is running\n')
     return srv
end

function run_telnet_server()
    srv=net.createServer(net.TCP, 180) 
    srv:listen(8080,function(c)
        con_std = c 
        uart.on("data", "\r",function(data)
            con_std:send(data)
            if data=="quit\r" then uart.on("data") end        
        end, 0) 
        c:on("receive",function(c,l) uart.write(0,l) end) 
        c:on("disconnection",function(c) uart.on("data") con_std = nil end) 
    end)
    print('Telnet server is running\n')
    return srv
end

function log_dht(file_name)
    if file_name then name = file_name else name = 'log.txt' end
    ok, temp, hum = dht.read(4)
    if ok == 0 then
        if file.open(name, 'a+') then
            file.writeline(''..tmr.time()..' '..temp..' '..hum..'')
            file.close()
        end
    end
end

function hsv2rgb(h, s, v)
    if s == 0 then return v, v, v end
    base = (255 - s)*v/256
    i = h/60
    if i == 0 then r, g, b = v, (((v-base)*h)/60)+base, base
    elseif i == 1 then r, g, b = (((v-base)*(60-(h%60)))/60)+base, v, base
    elseif i == 2 then r, g, b = base, v, (((v-base)*(h%60))/60)+base
    elseif i == 3 then r, g, b = base, (((v-base)*(60-(h%60)))/60)+base, v
    elseif i == 4 then r, g, b = (((v-base)*(h%60))/60)+base, base, v
    elseif i == 5 then r, g, b = v, base, (((v-base)*(60-(h%60)))/60)+base
    end
    return r, g, b
end

function write_rgb(r, g, b)
   leds = string.char(r,g,b,r,g,b)
   ws2812.writergb(2, leds)
end

function write_hsv(h, s, v)
   r,g,b = hsv2rgb(h, s or 255, v or 255) 
   leds = string.char(r,g,b,r,g,b)
   ws2812.writergb(2, leds)
end

function rainbow(delay, s,v)
   _step = function ()
       color = 0
       return function ()
           if color>359 then color = 0
           else color = color + 1 end
           write_hsv(color, s, v)
       end
    end
   tmr.alarm(3,delay or 30,tmr.ALARM_AUTO, _step())
end

_co2=nil
_co2_start=nil
function co2_on(pin)
   gpio.mode(pin, gpio.INT)
   gpio.trig(pin,"both",function (lvl) 
      tmr.wdclr()
      if lvl==1 then _co2_start=tmr.now() end
      tmr.wdclr()
      if lvl==0 then _co2=tmr.now()-_co2_start end 
   end)
end

function co2_off(pin)
   gpio.trig(pin,"none")
end

function get_co2_ppm()
   return 5*(_co2-2000)/1000
end

function co2_rgb()
   lvl = (5*(_co2-2000)/1000-400)/50
   if lvl < 0 then lvl=0 end
   if lvl >100 then lvl=100 end
   write_hsv(365*lvl/100)
end

_cnt_alt=0
_co2_alt=0
function co2_on_alt(pin)
   gpio.mode(pin, gpio.INT)
   function int_c(lvl)
      tmr.wdclr()
      gpio.mode(pin, gpio.INPUT)
      tmr.alarm(1,50,tmr.ALARM_AUTO,function ()
         if gpio.read(pin)==1 then _cnt_alt=_cnt_alt+50000
         else 
            tmr.unregister(1)
            _co2_alt=_cnt_alt
            _cnt_alt=0
            gpio.mode(pin, gpio.INT)
            gpio.trig(pin,"up",int_c)
         end
      end)
   end
   gpio.trig(pin,"up",int_c)
end
