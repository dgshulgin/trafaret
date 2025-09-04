local _context = nil -- локальная копия контекста для использования в виджетах

-- настройки диалогового окна
local setup = {
    -- идентификатор листа данных
    wid = 0, 
    -- номер строки заголовка по умолчанию
    header = 1, 
    -- путь к документу-шаблону
    template = nil, 
    -- путь к каталогу для сохранения документов
    out_folder = nil,
    -- создавать копию файла в PDF 
    pdf = false, 
}

-- описание окна
-- выбор листа данных --
local lblWorksheet = widgets.Label("Лист данных:", 100, 28)
lblWorksheet:setAlignment(Forms.Alignment_MiddleCenter)
-- список листов заполняется позднее
local  cmbWorksheet = widgets.ComboBox(nil, 150, 28)
cmbWorksheet:setOnCurrentItemChanged(function(id)
    setup.wid = id
end)
local blockWorksheet = ui:Row{ lblWorksheet, cmbWorksheet }

-- номер строки заголовка --
local lblHeaderLine = widgets.Label("Строка заголовка:", 150, 28)
lblHeaderLine:setAlignment(Forms.Alignment_MiddleCenter)
local textHeaderLine = widgets.TextBox(tostring(setup.header), 100, 28)
textHeaderLine:setOnEditingFinished(function()
    setup.header = tonumber(textHeaderLine:getText())
end)
local blockHeaderLine = ui:Row{ lblHeaderLine, textHeaderLine }

-- выбор файла шаблона --
local btnTemplate = widgets.Button("Выберите документ-шаблон", 380, 28)
btnTemplate:setOnClick(function()
    local dlg = ui:FileOpenDialog {
        Title = "Выбор шаблона",
        InitialDirectory = nil,
        Filter = "Все файлы (*.docx *.xlsx *.odt *.ods);;Word 2007-365 (*.docx);;Excel 2007-365 (*.xlsx);;ODF Text Document (*.odt);;ODF Spreadsheet (*.ods)", 
        AllowMultiSelect = false,
        OnDone = function(paths, filter)
            if paths:size() > 0 then
                setup.template = paths[0]
            end
        end
    }
    _context.showDialog(dlg)        
end)

-- выбор папки для сохранения документа --
local btnFolder = widgets.Button("Выберите папку для сохранения документов", 380, 28)
btnFolder:setOnClick(function()
    local dlg = ui:FolderDialog {
        Title = "Выбор папки",
        InitialDirectory = nil,
        OnDone = function(path)
            setup.out_folder = path
        end
    }
    _context.showDialog(dlg)
end)

-- флаг создания копии PDF
local cbxBuildPDF = widgets.CheckBox("Создать копию в формате PDF", 380, 28)
cbxBuildPDF:setOnStateChanged(function(state)
    setup.pdf = false
    if state > 0 then
        setup.pdf = true
    end
end)

-- кнопка запуска процесса формирования документов --
local btnStart = widgets.Button("Сформировать документы", 380, 28)
btnStart:setOnClick(function()
    local worker = require("model.publisher")
    local status, ret = pcall(worker.Run, _context, setup)
    if status ==  false then
        local text = require("service.text")
        local msg = utf8.substr(ret, text.InStr(ret, "#") + 1, utf8.len(ret))
        EditorAPI.messageBox(msg, "Трафарет")
        return
    end        
    EditorAPI.messageBox("Формирование документов завершено!", "Трафарет")
end)

-- диалоговое окно --
local closeButtons = ui:DialogButtons{}
closeButtons:addButton("Завершить", Forms.DialogButtonRole_Accept)

local mainForm = ui:Dialog{
Size = Forms.Size(430, 270),
    ui:Column {
    blockWorksheet, blockHeaderLine, btnTemplate, btnFolder, cbxBuildPDF, ui:Spacer{}, btnStart}}

function Run(context)
    _context = context

    -- заполнить список табличных листов на форме
    local names = {}
    context.doWithDocument(function(dataDoc)
        for t in dataDoc:getBlocks():enumerateTables() do
            table.insert(names, t:getName())
        end
    end)
    widgets.Reset(cmbWorksheet, names)

    -- Настройки конфигурации указывают, что выходные файлы формируются только в формате PDF.
    -- На диалоговом окне флаг "Создать копию в формате PDF" принудительно установлен и 
    -- запрещен для изменения.
    -- Это связано с безусловным добавлением watermark в нижний колонтитул документа.
    -- Если флаг pdfonly не установлен, то выходные файлы формируются в DOCX и в PDF, если
    -- пользователь установил соот флаг на диалоговом окне.
    if settings.pdfonly then
        cbxBuildPDF:setState(Forms.CheckState_Checked)
        cbxBuildPDF:setEnabled(false)
        setup.pdf = true
    end

    mainForm:setButtons(closeButtons)
    context.showDialog(mainForm)    
end

return {
    id       = "dialog",
    menuItem = "Сформировать документы",
    command  = Run,
}
