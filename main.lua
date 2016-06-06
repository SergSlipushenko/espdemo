co2 = -1
pwm = -1
verbose = 0
gpio.mode(1, gpio.INT)
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
get_ppm = function()
    ppm = (co2-2000)*4/1000
    if verbose>0 then print(string.format('\n%d: CO2 ppm==>%d',tmr.time(),ppm)) end
    n = to_level(ppm)
	write_rgb(0,42,0,8)
    if n>0 then write_rgb(42,0,0,n) end
end
msc = function(l) 
    if l==1 then pwm = tmr.now() 
    else if pwm>0 then co2=tmr.now()-pwm
                       pwm=-1
                       gpio.trig(1, "none")
                       get_ppm() end 
    end 
end
ms_co2 = function() gpio.trig(1, "both", msc) end
log_co2 = function() tmr.alarm(0, 10000, tmr.ALARM_AUTO, ms_co2) end
stop = function() tmr.stop(0) end

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

function write_rgb(r, g, b, n)
   led, leds = string.char(r,g,b), ''
   for i = 1,n or 1 do leds = leds .. led end
   ws2812.writergb(2, leds)
end

function write_hsv(h, s, v)
   r,g,b = hsv2rgb(h, s or 255, v or 255)
   leds = string.char(r,g,b,r,g,b)
   ws2812.writergb(2, leds)
end

log_co2()
