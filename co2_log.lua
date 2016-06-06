co2 = -1; pwm = -1; gpio.mode(1, gpio.INT)
get_ppm = function() print(string.format('\n%d: CO2 ppm==>%d',tmr.time(),(co2-2000)*4/1000)) end
msc = function(l) if l==1 then pwm = tmr.now() else if pwm>0 then co2=tmr.now()-pwm;pwm=-1;gpio.trig(1, "none");get_ppm() end end end
ms_co2 = function() gpio.trig(1, "both", msc) end
ms_co2()
get_ppm()
