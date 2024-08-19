
module("luci.controller.dogcom", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/dogcom") then
        return
    end
    local page
    page = entry({"admin", "school", "dogcom"}, cbi("dogcom"), _("Dr通用"), 100)
    page.i18n = "dogcom"
    page.dependent = true
end
