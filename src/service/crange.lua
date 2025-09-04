-- Выполняет функцию func для каждой ячейки диапазона.
-- Если acc не равен nil, то выполняет роль аккумулятора 
-- результатов обработки func
-- @param wks DocumentAPI.Table - табличный лист
-- @param addr string - адрес диапазона в формате A1, например, "B2:C5"
-- @param addr DocumentAPI.CellRangePosition - адрес диапазона в формате позиции
-- @param func function(DocumentAPI.Cell) - функция-обработчик ячейки в диапазоне.
-- @param acc table - таблица аккумулирует результаты обработки func.
-- Функция-обработчик принимает значение DocumentAPI.Cell - ячейку для обработки,
-- и возвращает значение любого типа. Возвращаемое значение помещается в таблицу acc,
-- если этот аргумент не равен nil при вызове функции.
function forEachCell(wks, addr, func, acc)
    assert(type(acc) == "table" or type(acc) == "nil",  "#неправильный тип аккумулятора")
	local cr = wks:getCellRange(addr)
	for cell in cr:enumerate() do
		local ret = func(cell)
		if acc then
			table.insert(acc, ret)
		end
	end
end

-- wrapper for DocumentAPI.CellPosition
function CellPos(r, c)
    return DocumentAPI.CellPosition(r, c)
end

-- wrapper for DocumentAPI.CellRangePosition
function RangePos(r, c, r1, c1)
    return DocumentAPI.CellRangePosition( CellPos(r,c), CellPos(r1,c1) )
end

-- column - опорный столбце для которого ведется подчет строк
-- идем вниз по строкам столбца column и проверяем, является ли ячейка пустой
-- true, если ячейка пуста
-- false, если ячейка не пуста
function getDataRowsCount(tab, baseCol, startRow)
    local isEmpty = function(cell)
        return cell:getFormattedValue() == ""
    end

    local rows = tab:getRowsCount()
    startRow = startRow == nil and 1 or startRow
    for r = startRow, rows do
        -- CellPosition нумерация с нуля
        local cell = tab:getCell( DocumentAPI.CellPosition(r-1, baseCol) )
        if isEmpty(cell) then
            return r - startRow
        end
    end
    return rows - startRow
end

-- row - опорная строка для которой ведтся подсчет столбцов
-- идем вправо по строке и проверяем не является ли ячейка пустой
function getDataColumnsCount(tab, baseRow, startCol)
    local isEmpty = function(cell)
        return cell:getFormattedValue() == ""
    end

    local cols = tab:getColumnsCount()
    startCol = startCol == nil and 1 or startCol
    for c = startCol, cols do
        -- CellPosition нумерация с нуля
        local cell = tab:getCell( DocumentAPI.CellPosition(baseRow, c-1) )
        if isEmpty(cell) then
            return c - startCol
        end
    end
    return cols - startCol
end


return {
    -- версия
    _version = "0.1.0",
    -- константы
    -- функции
    forEachCell = forEachCell,
    CellPos     = CellPos,
    RangePos    = RangePos,

    getDataRowsCount    = getDataRowsCount,
    getDataColumnsCount = getDataColumnsCount,
}