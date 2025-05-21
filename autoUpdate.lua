local dlstatus = require('moonloader').download_status
local inicfg = require('inicfg')

update_state = false

local script_vers = 2
local script_vers_text = "1.01"

local update_url = "https://raw.githubusercontent.com/Ajistika228/Luxwen-Tools/refs/heads/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://github.com/Ajistika228/Luxwen-Tools/raw/refs/heads/main/autoUpdate.luac"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("update", function()
        sampShowDialog(1231, "Автообновление", "Ура ебать успех нахуй", "Закрыть", "", 0)
    end)

    local success, err = pcall(function()
        downloadUrlToFile(update_url, update_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                sampAddChatMessage("Обновление...111", -1)
                if doesFileExist(update_path) then
                    sampAddChatMessage("INI файл скачан", -1)
                    local updateini = inicfg.load(nil, update_path)
                    if updateini then
                        sampAddChatMessage("INI загружен", -1)
                        if updateini.info then
                            sampAddChatMessage("Секция info найдена", -1)
                            if updateini.info.vers then
                                sampAddChatMessage("vers: " .. updateini.info.vers, -1)
                                local new_vers = tonumber(updateini.info.vers)
                                if new_vers then
                                    if new_vers > script_vers then
                                        sampAddChatMessage("Есть обновление! Версия: " .. updateini.info.vers_text, -1)
                                        update_state = true
                                    else
                                        sampAddChatMessage("Версия не новее текущей", -1)
                                    end
                                else
                                    sampAddChatMessage("vers не является числом", -1)
                                end
                            else
                                sampAddChatMessage("Нет ключа vers в секции info", -1)
                            end
                        else
                            sampAddChatMessage("Нет секции info", -1)
                        end
                    else
                        sampAddChatMessage("Не удалось загрузить INI", -1)
                    end
                    os.remove(update_path)
                else
                    sampAddChatMessage("Не удалось скачать INI файл", -1)
                end
            end
        end)
    end)
    if not success then
        sampAddChatMessage("Ошибка при запуске скачивания: " .. err, -1)
    end

    while true do
        wait(0)
        if update_state then
            sampAddChatMessage("Обновление...2222", -1)
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Обновление завершено!", -1)
                    thisScript():reload()
                    update_state = false
                end
            end)
            update_state = false  -- Чтобы не зацикливалось
        end
    end
end