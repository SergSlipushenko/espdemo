print('\ninit.lua\n5 sec for the rescue\n')
function main() dofile('main.lua') end
tmr.alarm(0, 5000, 0, function() main() end)
