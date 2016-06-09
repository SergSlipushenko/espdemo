htu21d = {
	init = function () i2c.setup(0, 2, 1, i2c.SLOW)	end,
	read = function (reg)
		i2c.start(0)
		i2c.address(0, 64, i2c.TRANSMITTER)
		i2c.write(0, reg)
		i2c.stop(0)
		tmr.delay(50000)
		i2c.start(0)
		i2c.address(0, 64, i2c.RECEIVER)
		c=i2c.read(0, 3)
		i2c.stop(0)
		return c:byte(1)*256+c:byte(2)
	end,
    temp = function (self)  return 17572*self.read(243)/65536-4685 end,
    hum = function (self) return 125*self.read(245)/65536-6 end
}
