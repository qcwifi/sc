module("luci.controller.mentohust", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/mentohust") then
        return
    end
    if luci.sys.call("command -v mentohust >/dev/null") ~= 0 then
        return
    end
    entry({"admin", "school", "mentohust"},
        alias("admin", "school", "mentohust", "general"),
        _("锐捷认证"), 20).dependent = true

    entry({"admin", "school", "mentohust", "general"}, cbi("mentohust/general"), _("基本设置"), 10).leaf = true
    entry({"admin", "school", "mentohust", "log"}, cbi("mentohust/log"), _("拨号日志"), 20).leaf = true
end
