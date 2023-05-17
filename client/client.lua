ESX = nil
local PlayerData = {}
local display = false
local currentGarage
local currentType

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    PlayerData = ESX.GetPlayerData()
end)

--------------------------
-- Next to NPC Trigger --
--------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for i = 1, #Config, 1 do
            item = Config[i]
            local dist = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), vector3(item.position.x, item.position.y, item.position.z))
            if dist <= 2.0 then
                if display == false then
                    local text = getText("HelpMessageNotification")
                    local output = text:gsub("{0}", item.name)
                    ESX.ShowHelpNotification(output)
                end
                if IsControlJustPressed(1, 51) then
                    openGarage("garage", true, item.name, General.color, getText("Park_in"), getText("Park_out"), getText("Action"), getText("Search_Keyword"))
                    currentGarage = item.name
                    currentType = item.type
                end
            end
        end
    end
end)

---------------------
-- RENAME FUNCTION --
---------------------
RegisterCommand("rename", function(source)
    if source > 0 then
        return
    end

    if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        ESX.TriggerServerCallback('nk_garage:isPlayerOwner', function(ownedVehicle)
            if ownedVehicle ~= false then
                ESX.TriggerServerCallback('nk_garage:nameTagFromVehicle', function(nametag)
                    openRename("rename", true, General.color, nametag)
                end, GetVehicleNumberPlateText(vehicle))
            end
        end, GetVehicleNumberPlateText(vehicle))
    end
end, false)


--------------------------
-- Blip and NPC Creator --
--------------------------
Citizen.CreateThread(function()
    local i = 1
    for _, item in pairs(Config) do
        if item.blips.showBlip == true then
            item.blip = AddBlipForCoord(item.position.x, item.position.y, item.position.z)
            SetBlipSprite(item.blip, item.blips.type)
            SetBlipDisplay(item.blip, 4)
            SetBlipScale(item.blip, 0.75)
            SetBlipColour(item.blip, item.blips.colour)
            SetBlipAsShortRange(item.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(item.blips.name)
            EndTextCommandSetBlipName(item.blip)
        end
        
        currentModel = GetHashKey(item.npc.model_hash)
        RequestModel(currentModel)

        while not HasModelLoaded(currentModel) do
            Wait(1)
        end

        ped = CreatePed(0, currentModel, item.position.x, item.position.y, item.position.z - 1, item.position.rotation, item.npc.networkSync)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        if item.npc.hasAnimation == true then
            TaskStartScenarioInPlace(ped, item.npc.animation, 0, true)
        end

    end
end)

-----------------
-- SetDisplay  --
-----------------
function openGarage(types, bool, gName, colour, sPark_in, sPark_out, sAction, sSearch)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = types,
        call = bool,
        name = gName,
        color = colour,
        park_in_name = sPark_in,
        park_out_name = sPark_out,
        action_name = sAction,
        search_name = sSearch
    })
end

function openRename(types, bool, colour, nametag)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        color = colour,
        type = types,
        call = bool,
        cNameTag = nametag
    })
end

function close()
    display = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "window",
        call = false
    })
end

function addStoredVehicles(vehicleName, sPlate, sNametag, id2)
    SendNUIMessage({
        type = "addStoredVehicle",
        id = id2,
        name = vehicleName,
        plate = sPlate, 
        nametag = sNametag
    })
end

-------------------
-- NUI CALLBACKS --
-------------------
RegisterNUICallback("exit", function(data, cb)
    close() display = false
    cb('ok')
end)

RegisterNUICallback("nk_garage:rowStoredVehicles", function(data, cb) 
    ESX.TriggerServerCallback('nk_garage:loadVehicles', function(vehicles)
        if #vehicles ~= 0 then
            for _,v in pairs(vehicles) do
                local data = json.decode(v.vehicle)
                local hashVehicule = data.model
                local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
                local vehicleName = GetLabelText(aheadVehName)
                local plate = v.plate
                local nametag = v.nk_nametag
                local id = v.ID
                addStoredVehicles(vehicleName, plate, nametag, id)
            end
        end
    end, currentType, currentGarage)
    cb('ok')
end)

RegisterNUICallback("nk_garage:setVehicleName", function(data, cb) 
    local text = getText("newNametagMessage")
    local output = text:gsub("{0}", GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))):gsub("{1}", data.nameFromCurrentVehicle)

    ESX.ShowAdvancedNotification(getText("Mechanic_Name"), getText("Concern_Out"), output, General.notification.mechanic_picture, 1)
    TriggerServerEvent('nk_garage:ChangeVehicleName', GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false)), data.nameFromCurrentVehicle)
end)

RegisterNUICallback("nk_garage:spawnVehicle", function(data, cb)
    ESX.TriggerServerCallback('nk_garage:spawnServerVehicle', function(vehicle)
        local data = json.decode(vehicle[1].vehicle)
        local i = 1
        local goal
        local goal2
        local spawn = false

        for _,v in pairs(Config) do
            if(v.name == currentGarage) then
                zone = v.zones[i]
                found = false
                i = 1
                while(i ~= #v.zones+1) and (found ~= true) do
                    if ESX.Game.IsSpawnPointClear(v.zones[i].vector, 3.5) then
                        goal = v.zones[i].vector
                        goal2 = v.zones[i].rotation
                        found = true
                    end
                    i = i+1
                    if i == #v.zones+1 then
                        canSpawn = false
                    end 
                end
            end
        end
        if(found ~= true) then
            ESX.ShowAdvancedNotification(getText("Mechanic_Name"), getText("Concern_Out"), getText("outpark_error"), General.notification.mechanic_picture, 1)
        else
            if spawn == false then
                ESX.Game.SpawnVehicle(data.model, goal, goal2, function(callback_vehicle)
                ESX.Game.SetVehicleProperties(callback_vehicle, data)
                    SetVehRadioStation(callback_vehicle, "OFF")
                    SetVehicleDoorsLocked(callback_vehicle, 2)
                    spawn = true
                end)
                ESX.ShowAdvancedNotification(getText("Mechanic_Name"), getText("Concern_Out"), getText("Successfully_Parked_Out"), General.notification.mechanic_picture, 1)
            end
        end
    end, data.selectedPlate)
    TriggerServerEvent('nk_garage:changeState', data.selectedPlate, 0)
    cb("ok")
end)

RegisterNUICallback("nk_garage:rowNextVehicles", function(data, cb)
    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(-1)), 25.0)
    for key, value in pairs(vehicles) do
        ESX.TriggerServerCallback('nk_garage:isPlayerOwner', function(ownedVehicle)
            if ownedVehicle == false then
                -- Not the Owner
            else
                ESX.TriggerServerCallback('nk_garage:getIdFromVehicle', function(id)
                    addStoredVehicles(GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(value))), GetVehicleNumberPlateText(value), ownedVehicle, id)
                end, GetVehicleNumberPlateText(value))
            end
        end, GetVehicleNumberPlateText(value))
    end
    cb("ok")
end)    

RegisterNUICallback("nk_garage:removeVehicle", function(data, cb)
    local plate = data.selectedPlate
    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(-1)), 25.0)

    for key, value in pairs(vehicles) do
        if GetVehicleNumberPlateText(value) == plate then
            TriggerServerEvent('nk_garage:saveProps', GetVehicleNumberPlateText(value), ESX.Game.GetVehicleProperties(value))
            TriggerServerEvent('nk_garage:changeState', GetVehicleNumberPlateText(value), 1)
            TriggerServerEvent('nk_garage:changeLocation', GetVehicleNumberPlateText(value), currentGarage)
            ESX.Game.DeleteVehicle(value)
            local text = getText("Successfully_Parked_In")
            local output = text:gsub("{0}", currentGarage)
            ESX.ShowAdvancedNotification(getText("Mechanic_Name"), getText("Concern_In"), output, General.notification.mechanic_picture, 1)        end
    end
    cb("ok")
end)

------------------------
-- Get language-text  --
------------------------
function getText(val) 
    local currentLangauge = General.lang
    return Locales[currentLangauge][val]
end