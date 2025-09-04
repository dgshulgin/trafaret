local platformMacOS     = "darwin"
local platformWindows   = "windows"
local platformLinux     = "linux"
local platformUndefined = nil

-- Определяет тип ОС анализируя значение package.cpath и возвращает
-- одну из констант platformXXX
-- @return string тип ОС
-- @return nil если не удалось определить ОС
function platform()
    local cpath = package.cpath
    if string.match(cpath, "(%.dll)") then
        return platformWindows
    end
    if string.match(cpath, "(%.so)") or string.match(cpath, "(%.dylib)") then
        local handle = io.popen('printf "$(uname)"')
        local result = string.lower(handle:read("*a"))
        handle:close()

        if string.match(result, platformMacOS) then
            return platformMacOS
        end
        if string.match(result, platformLinux) then
            return platformLinux
        end        
    end
    return platformUndefined
end

-- Формирует путь к файлу или каталогу в соотв с правилами ОС
-- @param string path - головная часть пути или nil или пустая строка
-- @param string tail - завершающая часть пути или nil или пустая строка
-- @return string - путь к файлу или каталогу или пустая строка, если 
--                  не удалось определить тип ОС
function join(path, tail)
    path = type(path) == "nil" and "" or path
    tail = type(tail) == "nil" and "" or tail
    local osv = platform()
    if osv == platformLinux or osv == platformMacOS then
        return path .. "/" .. tail
    end
    if osv == platformWindows then
        return path .. "\\" .. tail
    end
    -- не удалось определить ОС
    return ""
end

local modes = {
    { name = "debug",  },
    { name = "error",  },
}

-- Расположение лог-файла должно быть определено в переменной log.logfile
-- перед первым вызовом log.debug() или log.error().
-- Функции log.debug() и log.error() записывают сообщение в log.logfile и
-- возвращают текст сообщения.
local log = {}
log.logfile = nil
for idx, mode in ipairs(modes) do
    log[mode.name] = function(...)
        local param = tostring(...)
        local info = debug.getinfo(2, "Sl")
        local lineinfo = info.short_src .. ":" .. info.currentline
        local msg = string.format("[%-6s%s] %s: %s\n",
                                string.upper(mode.name), 
                                os.date(), 
                                lineinfo, 
                                param)

        if log.logfile then
            local fp = io.open(log.logfile, "a")
            fp:write(msg)
            fp:close()
        end
        return msg
    end
end
-- Пример работы
-- 1. запись в лог-файл
-- local env = require("environ")
-- env.log.logfile = "/tmp/my_ext.log"
-- env.debug("Debug message")
-- 2. лог-файл не определен, запись не происходит, но возвращается
-- строка сообщения
-- local env = require("environ")
-- local msg =  env.error("Error!")
-- EditorAPI.messageBox(msg)

return {
    -- версия
    _version = "1.0.0",
    -- константы
    platformMacOS     = platformMacOS,
    platformWindows   = platformWindows,
    platformLinux     = platformLinux,
    platformUndefined = platformUndefined,    
    -- функции
    platform = platform,
    join     = join,
    log      = log,
}
