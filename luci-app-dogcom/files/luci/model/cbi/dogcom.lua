
local m, s

local running = (luci.sys.call("pidof dogcom > /dev/null") == 0)
if running then 
    m = Map("dogcom", translate("Dogcom 设置"), translate("Dr.com 运行中。"))
else
    m = Map("dogcom", translate("Dogcom 设置"), translate("Dr.com 未运行。"))
end

s = m:section(TypedSection, "dogcom", "")
s.addremove = false
s.anonymous = true

-- Basic Settings --
s:tab("basic", translate("基本设置"))

enable = s:taboption("basic", Flag, "enabled", translate("启用"))
enable.rmempty = false
function enable.cfgvalue(self, section)
    return luci.sys.init.enabled("dogcom") and self.enabled or self.disabled
end

version = s:taboption("basic", ListValue, "version", translate("版本"))
version:value("dhcp", translate("dhcp（D版）"))
version:value("pppoe", translate("pppoe（P版）"))
version:value("8021", translate("8021.X"))
version.value = "dhcp"

escpatch = s:taboption("basic", Button, "esc", translate("P版转义字符补丁"))
function escpatch.write()
    luci.sys.call("sed -i '/proto_run_command/i username=`echo -e \"$username\"`' /lib/netifd/proto/ppp.sh")
    luci.sys.call("sed -i '/proto_run_command/i password=`echo -e \"$password\"`' /lib/netifd/proto/ppp.sh")
end

config = s:taboption("basic", Value, "config", translate("配置文件"), translate("This file is /etc/dogcom.conf."), "")
config.template = "cbi/tvalue"
config.rows = 15
config.wrap = "off"

function config.cfgvalue(self, section)
    return nixio.fs.readfile("/etc/dogcom.conf")
end

function config.write(self, section, value)
    value = value:gsub("\r\n?", "\n")
    nixio.fs.writefile("/etc/dogcom.conf", value)
end

-- Generate Configuration --
s:tab("generator", translate("生成配置"))

msg = s:taboption("generator", DummyValue, "", translate(""), 
translate("请上传你的数据包，然后修改密码并复制到基本设置配置文件中。"))

autoconfig = s:taboption("generator", DummyValue, "autoconfig")
autoconfig.template = "dogcom/auto_configure"

-- Save Configuration --
function enable.write(self, section, value)
    if value == "1" then
        luci.sys.call("/etc/init.d/dogcom enable >/dev/null")
        luci.sys.call("/etc/init.d/dogcom start >/dev/null")
    else
        luci.sys.call("/etc/init.d/dogcom stop >/dev/null")
        luci.sys.call("/etc/init.d/dogcom disable >/dev/null")
    end
    Flag.write(self, section, value)
end

return m
