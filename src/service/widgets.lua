local _widx = 0 -- индекс виджета
local _widx_inc = function() _widx = _widx + 1 return _widx end

function Label(text, width, height)
    return ui:Label{
        Name = "widget" .. tostring(_widx_inc()),
        Text = text,
        Enabled = true,
        Size = Forms.Size(width, height),
    }
end

function ComboBox(items, width, height, curr)
    local w =  ui:ComboBox{
        Name = "widget" .. tostring(_widx_inc()),
        Enabled = true,
        Size = Forms.Size(width, height),
        CurrentItem = type(curr) == "nil" and 0 or curr
    }
    if items and #items > 0 then
        for i, v in ipairs(items) do
            w:addItem(v, i)
        end
    end
    return w
end

function Reset(ctrl, items)
    -- clean up
    local olds = ctrl:getItems()
    if olds:getCount() > 0 then
        for i = 0, olds:getCount() do
            ctrl:removeItem(i)
        end
    end
    --set up
    if #items then
        for i,v in ipairs(items) do
            ctrl:addItem(v, i-1)
        end
    end
end

function TextBox(text, width, height)
    return ui:TextBox{
        Name = "widget" .. tostring(_widx_inc()),
        Text = text,
        Enabled = true,
        Size = Forms.Size(width, height),
    }
end

function Button(text, width, height,  onclick)
    local b =  ui:Button{
        Name = "widget" .. tostring(_widx_inc()),
        Title = text,
        Enabled = true,
        Size = Forms.Size(width, height),
    }    
    if onclick then
        b:setOnClick(onclick)
    end
    return b
end

function CheckBox(title, width, height, init)
    return ui:CheckBox{
        Name = "widget" .. tostring(_widx_inc()),
        Title = title,
        Enabled = true,
        Size = Forms.Size(width, height),
        State = type(init) == "nil" and Forms.CheckState_Unchecked or init,
    }
end

return {
    -- версия
    _version = "0.1.0",
    -- константы
    -- функции
    Label    = Label,
    Button   = Button,
    TextBox  = TextBox,
    CheckBox = CheckBox,
    ComboBox = ComboBox,
    
    Reset = Reset,
}