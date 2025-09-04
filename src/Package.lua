local manifest = {
    -- машиночитаемый идентификатор надстройки
    extensionID = "ru.myofficehub.trafaret",
    -- отображаемое имя надстройки
    extensionName = "Трафарет",
    -- имя/наименование разработчика
    vendor = "АНО \"Хаб Знаний МойОфис\"",

    description =   [[Автозаполнение шаблона документа данными из таблицы.]],
    
    apiVersion = {major=1, minor=0},
    extensionVersion = {major=1, minor=0, patch=0, build=""},
    applicationId = {"MyOffice Spreadsheet"},
    
    fallbackLanguage = "ru",

    commandsProvider = "app/trafaret.lua",
}
return manifest