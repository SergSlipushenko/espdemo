dofile('htu21d.lua')
htu21d.init()
co2 = 0
pwm = -1
verbose = 0
ledshow = 1 
ws2812.init()
pwm_pin = 5
gpio.mode(pwm_pin, gpio.INT)
function to_level(ppm)
    if ppm<350 then n=0
    elseif ppm<400 then n=1
    elseif ppm<560 then n=2
    elseif ppm<800 then n=3
    elseif ppm<1130 then n=4
    elseif ppm<1600 then n=5
    elseif ppm<2260 then n=6
    elseif ppm<3200 then n=7
    else n=8 end
    return n
end
log_data = function()
    temp = htu21d:temp()
    hum = htu21d:hum()
    if verbose>0 then 
        print('{"time":'..tmr.time()..',"co2":'..co2..',"temp":'..temp..',"hum":'..hum.."}") end
	if ledshow>0 then write_rgb(0,15,0,to_level(co2)) end
end
msc = function(l) 
    if l==1 then pwm = tmr.now() 
    else if pwm>0 then co2=(tmr.now()-pwm-2000)*4/1000
                       pwm=-1
                       gpio.trig(pwm_pin, "none")
                       log_data() end 
    end 
end
ms_co2 = function() gpio.trig(pwm_pin, "both", msc) end
log_co2 = function() tmr.alarm(0, 10000, tmr.ALARM_AUTO, ms_co2) end
stop = function() tmr.stop(0) end

function write_rgb(r, g, b, n, total, r1, g1, b1)
   led, back = string.char(r,g,b), string.char(r1 or 15,g1 or 0, b1 or 0)
   leds, n = '', n or 1
   for i = 1,total or 8 do 
       if i<=n then leds = leds .. led else leds = leds .. back end
   end
   ws2812.write(leds)
end

ws2812.write(string.char(255,0,0, 0,255,0, 0,0,255, 255,255,0, 128,0,128, 0,128,128, 80,80,80, 0,0,0))  
log_co2()
