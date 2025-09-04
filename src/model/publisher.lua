local LOGO_WIDTH  = 201 / 3 -- px
local LOGO_HEIGHT = 59 / 3-- px


function buildMarkers(wks, addr)
    local range = wks:getCellRange(addr)
    local markers = {}
    local col = 0
    for cell in range:enumerate() do
        local text = cell:getFormattedValue()
        if #text > 0 then
            markers[text] = col
        end
        col =  col + 1
    end
    return markers
end

function Run(context, setup)
    assert(setup.template,  "#Не указан документ-шаблон.")
    assert(setup.out_folder, "#Не указан каталог для размещения итоговых документов.")

    -- Расположение файла с логотипом для вставки watermark.
    copyBundledFile("resources/logo.png", "resources/logo.png", "ignore")
    local logo_url = env.join(getWorkingDirectory()) .. env.join("resources", "logo.png")

    -- docData рабочий табличный документ
    context.doWithDocument(function(docData)

        local wks = docData:getBlocks():getTable(setup.wid)

        assert(setup.header > 0 and setup.header <= wks:getRowsCount(), 
            "#Указанный номер строки заголовка находится за пределами области данных." )
            
        -- определить кол-во строк данных после заголовка, считаем по столбцу A 
        local dataRows = crange.getDataRowsCount(wks, 1, setup.header+1)
        env.log.debug(string.format("найдено строк данных %d", dataRows ))
        assert(dataRows > 0, "#В табличном документе отсутствуют данные.")
            
        -- определить кол-во столбцов данных по строке заголовка
        local dataColumns = crange.getDataColumnsCount(wks,setup.header) 
        env.log.debug(string.format("найдено столбцов %d", dataColumns ))
            
        -- построить таблицу маркеров по заголовку
        -- { "marker"=col_index }
        local addr = crange.RangePos(setup.header-1, 0, setup.header-1, dataColumns)
        local markers = buildMarkers(wks, addr)
        env.log.debug(string.format("найдено маркеров %d", #markers))

        -- создание документов по шаблону
        context.doWithApplication(function(app)
            -- для каждой строки данных создается отдельный файл
            local file_index = 1 -- для формирования имени выходного файла
            for row = setup.header+1, dataRows do
                -- открыть файл шаблона
                local docTemplate = app:loadDocument(setup.template)
                local search = DocumentAPI.createSearch(docTemplate)
                -- в шаблоне заменить маркеры на значения в ячейках данных для текущей строки
                for mark, col in pairs(markers) do
                    local addr = crange.CellPos(row-1,col)
                    local subst = wks:getCell(addr):getFormattedValue()

                    local ranges = search:findText( string.format("{%s}", mark) )
                    for occ in ranges do
                        occ:replaceText(subst)
                    end
                end

                -- Настройки конфигурации указывают, что в выходной документ принудительно
                -- добавляется watermark. 
                if settings.watermark then
                    local section = docTemplate:getBlocks():getBlock(0):getSection()
                    local footers = section:getFooters()
                    for f in footers:enumerate() do
                        if f:getType() == DocumentAPI.HeaderFooterType_Footer then
                            local pos = f:getRange():getBegin()
                            local tab = pos:insertTable(1,6,"placeholder")

                            local addr = DocumentAPI.CellPosition(0,0)
                            local pos2 = tab:getCell(addr):getRange():getBegin()
                            pos2:insertImage(logo_url, DocumentAPI.SizeU(LOGO_WIDTH,LOGO_HEIGHT))
                            
                            local paras = tab:getCell(addr):getRange():getParagraphs()
                            for pr in paras:enumerate() do
                                local props = pr:getParagraphProperties()
                                props.alignment = DocumentAPI.Alignment_Right
                                pr:setParagraphProperties(props)
                            end

                            local lineProp = DocumentAPI.LineProperties()
                            lineProp.style = DocumentAPI.LineStyle_Solid
                            lineProp.width = 0.5
                            local lc = DocumentAPI.ColorRGBA(255,255,255,250)
                            lineProp.color = DocumentAPI.Color(lc)
                            
                            local borders = DocumentAPI.Borders()
                            -- настройка внешних границ
                            borders:setOuter(lineProp)
                            -- настройка внутренних границ
                            borders:setInner(lineProp)
                            
                            -- в реальной жизни этот диапазон высчитывается динамически,
                            -- а сейчас я взял готовые значения, повезло!
                            local addr = DocumentAPI.CellRangePosition(DocumentAPI.CellPosition(0,0), DocumentAPI.CellPosition(0,5))
                            local r = tab:getCellRange(addr)
                            r:setBorders(borders)                            
                        end
                    end                    
                end
                -- Настройки конфигурации указывают, что выходные документы формируются только
                -- в формате PDF. Есл флаг не установлен, то выходные файлы формируются, 
                -- также, в формате DOCX.
                if not settings.pdfonly then
                    -- сохранить изменения шаблона в отдельном документе
                    -- построить наименование итогового файла path/idx-<markerdata>.docx
                    local cfn = string.format("%s%d-%s.docx", 
                            env.join(setup.out_folder, ""),
                            file_index,
                            "")
                    local status, ret = pcall( function(filename) 
                                                return docTemplate:saveAs(filename)
                                                end, 
                                                cfn)
                    assert(status, "#Ошибка при сохранении документа " .. cfn ) 
                end

                -- сохранить копию в PDF
                -- В случае settings.pdfonly = true флаг setup.pdf принудительно устновлен
                -- в значение true на диалоговом окне.
                if setup.pdf then
                    local pdfName = string.format("%s%d-%s.pdf", 
                            env.join(setup.out_folder, ""),
                            file_index,
                            "")
                    docTemplate:exportAs(pdfName, DocumentAPI.ExportFormat_PDFA1)
                end
                file_index = file_index + 1                
            end
        end)
    end)

    return true, nil
end

return {
    -- константы
    -- функции
    Run = Run,
}