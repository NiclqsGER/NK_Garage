ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

MySQL.ready(function()
	MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = 1 WHERE `stored` = @stored', {
		['@stored'] = 0
	}, function(rowsChanged)
		if rowsChanged > 0 then
			print(('nk_garage: %s vehicle(s) have been stored!'):format(rowsChanged))
		end
	end)
end)

ESX.RegisterServerCallback('nk_garage:getIdFromVehicle', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT ID FROM owned_vehicles WHERE plate=@plate', {
        ['@plate'] = plate
    }, function(id) 
        cb(id[1].ID)
    end)
end)

ESX.RegisterServerCallback('nk_garage:nameTagFromVehicle', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT nk_nametag FROM owned_vehicles WHERE plate=@plate', {
        ['@plate'] = plate
    }, function(data) 
        cb(data[1].nk_nametag)
    end)
end)

ESX.RegisterServerCallback('nk_garage:loadVehicles', function(source, cb, type, garage)
    local vehicles = {}
    local s = source
    local p = ESX.GetPlayerFromId(s)

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner=@owner AND stored=1 AND nk_garage=@garage AND type=@type', {
        ['@owner'] = p.identifier, 
        ['@garage'] = garage,
        ['@type'] = type,
    }, function(vehicles) 
        cb(vehicles)
    end)
end)

ESX.RegisterServerCallback('nk_garage:spawnServerVehicle', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate=@plate', {['@plate'] = plate}, function(vehicle)
        cb(vehicle)
    end)
end)

ESX.RegisterServerCallback('nk_garage:isPlayerOwner', function(source, cb, plate)
    local s = source
    local p = ESX.GetPlayerFromId(s)

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate AND owner = @owner', {["@plate"] = plate, ['@owner'] = p.identifier}, function(vehicle)
        if next(vehicle) then
            local nametag = vehicle[1].nk_nametag
            cb(nametag)
        else
            cb(false)
        end
    end)
end)

RegisterNetEvent('nk_garage:ChangeVehicleName')
AddEventHandler('nk_garage:ChangeVehicleName', function(plate, nk_nametag)
    MySQL.Sync.execute("UPDATE owned_vehicles SET nk_nametag = @nk_nametag WHERE `plate` = @plate", {['@nk_nametag'] = nk_nametag, ['@plate'] = plate})
end)

RegisterNetEvent('nk_garage:changeState')
AddEventHandler('nk_garage:changeState', function(plate, state)
	MySQL.Sync.execute("UPDATE owned_vehicles SET `stored` = @state WHERE `plate` = @plate", {['@state'] = state, ['@plate'] = plate})
end)

RegisterNetEvent('nk_garage:changeLocation')
AddEventHandler('nk_garage:changeLocation', function(plate, garage)
	MySQL.Sync.execute("UPDATE owned_vehicles SET nk_garage = @garage WHERE `plate` = @plate", {['@garage'] = garage, ['@plate'] = plate})
end)

RegisterNetEvent('nk_garage:saveProps')
AddEventHandler('nk_garage:saveProps', function(plate, props)
	local xProps = json.encode(props)
	MySQL.Sync.execute("UPDATE owned_vehicles SET `vehicle` = @props WHERE `plate` = @plate", {['@plate'] = plate, ['@props'] = xProps})
end)