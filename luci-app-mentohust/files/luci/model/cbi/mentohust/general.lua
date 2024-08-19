local function is_running(name)
    if luci.sys.call("pidof %s >/dev/null" %{name}) == 0 then
        return translate("运行中")
    else
        return translate("未运行")
    end
end

local function is_online(ipaddr)
    if ipaddr == "0.0.0.0" then 
        return translate("没有设置Ping主机")
    end
    if luci.sys.call("ping -c1 -w1 %s >/dev/null 2>&1" %{ipaddr}) == 0 then
        return translate("已经能访问互联网")
    else
        return translate("不能访问互联网")
    end
end

require("luci.sys")

m = Map("mentohust", translate("MentoHUST"), translate("配置MentoHUST 802.11x验证。"))

s = m:section(TypedSection, "mentohust", translate("Status"))
s.anonymous = true
status = s:option(DummyValue,"_mentohust_status", "MentoHUST")
status.value = "<span id=\"_mentohust_status\">%s</span>" %{is_running("mentohust")}
status.rawhtml = true
t = io.popen('uci get mentohust.@mentohust[0].pinghost')
netstat=is_online(tostring(t:read("*line")))
t:close()
if netstat ~= "" then
netstatus = s:option(DummyValue,"_network_status", translate("网络状态"))
netstatus.value = "<span id=\"_network_status\">%s</span>" %{netstat}
netstatus.rawhtml = true
end

o = m:section(TypedSection, "mentohust", translate("设置"))
o.addremove = false
o.anonymous = true

o:tab("base", translate("常规设置"))
o:tab("advanced", translate("高级设置"))

enable = o:taboption("base", Flag, "enable", translate("启用"))
name = o:taboption("base", Value, "username", translate("用户名"),translate("您的用户名(或管理员分配的用户名)"))
pass = o:taboption("base", Value, "password", translate("密码"), translate("您的密码(或管理员分配的密码)"))
pass.password = true

ifname = o:taboption("base", ListValue, "ifname", translate("接口"), translate("WAN口的物理接口"))
for k, v in ipairs(luci.sys.net.devices()) do
    if v ~= "lo" then
        ifname:value(v)
    end
end

pinghost = o:taboption("base", Value, "pinghost", translate("Ping主机"), translate("Ping主机，用于掉线检测，0.0.0.0表示关闭该功能"))
pinghost.default = "180.76.76.76"

ipaddr = o:taboption("advanced", Value, "ipaddr", translate("IP地址"), translate("你的IPV4地址，DHCP用户可设为0.0.0.0"))
ipaddr.default = "0.0.0.0"

mask = o:taboption("advanced", Value, "mask", translate("子网掩码"), translate("掩码，无关紧要"))
mask.default = "0.0.0.0"

gateway = o:taboption("advanced", Value, "gateway", translate("网关"), translate("网关，如果指定了就会监视网关ARP信息"))
gateway.default = "0.0.0.0"

dnsserver = o:taboption("advanced", Value, "dns", translate("DNS服务器"), translate("DNS服务器，无关紧要"))
dnsserver.default = "0.0.0.0"

timeout = o:taboption("advanced", Value, "timeout", translate("验证超时"), translate("每次发包超时时间（秒）"))
timeout.default = "8"

echointerval = o:taboption("advanced", Value, "echointerval", translate("Echo包间隔"), translate("发送Echo包的间隔（秒）"))
echointerval.default = "30"

restartwait = o:taboption("advanced", Value, "restartwait", translate("验证失败等待时间"), translate("失败等待（秒）认证失败后等待多少秒或者服务器请求后重启认证"))
restartwait.default = "15"

startmode = o:taboption("advanced", ListValue, "startmode", translate("组播地址类型"), translate("寻找服务器时的组播地址类型(某些交换机可能会丢弃标准包)"))
startmode:value(0, translate("标准"))
startmode:value(1, translate("锐捷"))
startmode:value(2, translate("将MentoHUST用于赛尔认证"))
startmode.default = "1"

dhcpmode = o:taboption("advanced", ListValue, "dhcpmode", translate("DHCP设置"), translate("DHCP方式"))
dhcpmode:value(0, translate("无"))
dhcpmode:value(1, translate("二次认证"))
dhcpmode:value(2, translate("认证后"))
dhcpmode:value(3, translate("认证前"))
dhcpmode.default = "1"

shownotify = o:taboption("advanced", Value, "shownotify", translate("通知级别"), translate("是否显示通知： 0(否) 1~20(是)"))
shownotify.default = "5"

version = o:taboption("advanced", Value, "version", translate("客户端版本号"), translate("客户端版本号，如果未开启客户端校验但对版本号有要求，可以在此指定，形如3.30"))
version.default = "0.00"

datafile = o:taboption("advanced", Value, "datafile", translate("数据文件"), translate("认证数据文件，如果需要校验客户端，就需要正确设置为/tmp/rj84/etc/mentohust/DataPackA.mpf"))
datafile.default = "/tmp/rj84/etc/mentohust/"

dhcpscript = o:taboption("advanced", Value, "dhcpscript", translate("DHCP的脚本"), translate("进行DHCP的脚本"))
dhcpscript.default = "udhcpc -i"

local apply = luci.http.formvalue("cbi.apply")
if apply then
    io.popen("/etc/init.d/mentohust restart")
end

return m
