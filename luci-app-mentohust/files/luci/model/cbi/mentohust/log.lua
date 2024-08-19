local fs = require "nixio.fs"

local f = SimpleForm("mentohust",
	translate("拨号日志"),
	translate("日志文件：/tmp/mentohust.log"))

local o = f:field(Value, "mentohust_log")

o.template = "cbi/tvalue"
o.rows = 32

function o.cfgvalue(self, section)
	return fs.readfile("/tmp/mentohust.log")
end

function o.write(self, section, value)
	require("luci.sys").call('cat /dev/null > /tmp/mentohust.log 2>/dev/null')
end

f.submit = translate("Clear log")
f.reset = false

return f