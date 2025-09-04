local text = {}

-- возвращает начальную позицию вхождения str2 в str1, либо -1
-- TODO naive, refactor
text.InStr = function(str1, str2)
    if str1 == str2 then return 1 end

    local len1 = utf8.len(str1)
    local len2 = utf8.len(str2)
    if len2 > len1 then return -1 end
    
    local diff = len1 - len2
    for idx=1,diff do
        local sub = utf8.substr(str1, idx, len2 - 1 + idx)
        if sub == str2 then return idx end
    end
    return -1
end

return text