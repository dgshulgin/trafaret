local manifest = {
    -- машиночитаемый идентификатор надстройки
    extensionID = "ru.myofficehub.trafaret",
    -- отображаемое имя надстройки
    extensionName = "Трафарет",
    -- имя/наименование разработчика
    vendor = "АНО \"Хаб Знаний МойОфис\"",

    description =   [[Заполняет шаблон тестового документа испольщуя данные электронной таблицы. Принудительно добавляет логотип Хаб Знаний в нижний колонтитул первого листа.]],
    
    apiVersion = {major=1, minor=0},
    extensionVersion = {major=1, minor=1, patch=0, build=""},
    applicationId = {"MyOffice Spreadsheet"},
    
    fallbackLanguage = "ru",

    commandsProvider = "app/trafaret.lua",
}
return manifest