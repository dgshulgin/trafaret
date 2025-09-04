_G.crange = require("service.crange")
_G.widgets = require("service.widgets")

_G.env    = require("service.environ")
--env.log.logfile = "/tmp/trafaret.log"


_G.settings = {pdfonly = true, watermark=true, }
configFile, error = openBundledFile(env.join("app","settings.json"))
if not error then
    local content = configFile:read "*a"
    configFile:close()
    local json = require('service.dkjson')
    local settings_json = json.decode(content)

    env.log.logfile = #settings_json.logpath > 0 and settings_json.logpath or nil
    
    settings.pdfonly = settings_json.pdfonly
    env.log.debug(settings.pdfonly and "pdfonly set" or "pdfonly unset")
    settings.watermark = settings_json.watermark
    env.log.debug(settings.watermark and "watermark set" or "watermark unset")
end

function getCommands ()
    local handlers = {}
    --table.insert(handlers, require("view.dialog").getHandler())
    table.insert(handlers, require("view.dialog"))
    return handlers
end

return {
    getCommands = getCommands,
}