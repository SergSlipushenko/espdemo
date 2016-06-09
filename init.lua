print('\ninit.lua\n5 sec for the rescue\n')
function main() dofile('main.lua') end
if not file.exists("run.lock") then tmr.alarm(0, 5000, 0, function() main() end) end
