lib.locale()

print("^200_garage by sum00er. https://discord.gg/pjuPHPrHnx")

lib.callback.register('00_garage:getVehicles', function(source)
	local identifier = GetIdentifier(source)
	local result = MySQL.query.await('SELECT * FROM '..sql_table..' WHERE '..sql_id..' = ?',{identifier})

	local vehicles = {['0'] = {}, ['1'] = {}}
	for i = 1, #result, 1 do
		if type(result[i][sql_stored]) ~= 'number' then
			print('[ERROR] Please run SQL before using the script')
			return
		end
		if result[i][sql_stored] ~= 1 then result[i][sql_stored] = 0 end
		table.insert(vehicles[tostring(result[i][sql_stored])], {
			vehicle 	= json.decode(result[i][sql_props]),
			job			= result[i].job,
			plate 		= result[i].plate,
			parking		= result[i][sql_stored] == 1 and (result[i][sql_parking] or locale('garage')) or locale('impound')
		})
	end

	return vehicles
end)

lib.callback.register('00_garage:checkVehicleOwner', function(source, plate, job)
	local identifier = GetIdentifier(source)
	local query = 'SELECT COUNT(*) as count FROM '..sql_table..' WHERE '..sql_id..' = ? AND `plate` = ?'
	if job then
		query = query..' AND `job` = ?'
	end
	local result = MySQL.query.await(query,{identifier, plate, job})
	if tonumber(result[1].count) > 0 then
		return true
	else
		return false
	end
end)

RegisterServerEvent('00_garage:updateOwnedVehicle')
AddEventHandler('00_garage:updateOwnedVehicle', function(stored, parking, vehicleProps, entity, shouldPay, id)
	local source = source
	if entity and stored == 1 then
		local Vehicle = NetworkGetEntityFromNetworkId(entity)
		if DoesEntityExist(Vehicle) then
			DeleteEntity(Vehicle)
		end
	end
	if shouldPay then
		local money = GetMoney(source)
		if money >= Config.ImpoundCost then
			RemoveMoney(source, Config.ImpoundCost)
			TriggerClientEvent('00_garage:showNotification', source, locale('pay_Impound_bill', Config.ImpoundCost))
		else
			TriggerClientEvent('00_garage:showNotification', source,locale('missing_money'))
			local Vehicle = NetworkGetEntityFromNetworkId(entity)
			if DoesEntityExist(Vehicle) then
				DeleteEntity(Vehicle)
			end
			return
		end
	end
	local identifier = GetIdentifier(source)
	if id then
		identifier = id
	end
	MySQL.update('UPDATE '..sql_table..' SET '..sql_stored..' = ?, '..sql_props..' = ?, '..sql_parking..' = ? WHERE plate = ? AND '..sql_id..' = ?',{stored, json.encode(vehicleProps), parking, vehicleProps.plate, identifier})
	if stored == 1 then
		TriggerClientEvent('00_garage:showNotification', source, locale('veh_stored'))
		lib.logger(source, locale('log_store'), locale('log_store'), locale('plate')..':'..vehicleProps.plate, locale('garage')..':'..(garage or 'unknown'))
	end
end)

lib.callback.register('00_garage:spawnVehicle', function(source, plate, model, vehType, coords, heading, garage)
	if Config.retrieveVerify then
		local source = source
		local veh = GetAllVehicles()
		local my_ped = GetPlayerPed(source)
		local found, canDel = false, nil
		for k, v in pairs(veh) do
			local veh_plate = GetVehicleNumberPlateText(v)
			if Config.trimPlate then
				veh_plate = string.strtrim(veh_plate)
			end
			if veh_plate == plate then
				found = true
					local last_ped = GetLastPedInVehicleSeat(v, -1)
					if last_ped == my_ped or last_ped == 0 or GetVehicleEngineHealth(v) <= 100 or GetVehicleBodyHealth(v) <= 100 then
						canDel = v
					end
				break
			end
		end
		if found and canDel then
			if DoesEntityExist(canDel) then
				DeleteEntity(canDel)
			end
			TriggerClientEvent('00_garage:showNotification', source, locale('delete_existing'))
			lib.logger(source, locale('log_retrieve'), locale('log_retrieve_del'), locale('plate')..':'..plate, locale('garage')..':'..(garage or 'unknown'))
		elseif not found then
			lib.logger(source, locale('log_retrieve'), locale('log_retrieve'), locale('plate')..':'..plate, locale('garage')..':'..(garage or 'unknown'))
		else
			TriggerClientEvent('00_garage:showNotification', source, locale('cannot_take'))
			return false
		end
	end

	local veh = CreateVehicleServerSetter(model, vehType, coords.x, coords.y, coords.z - 0.9, heading)
    local netId = NetworkGetNetworkIdFromEntity(veh)
	SetVehicleNumberPlateText(veh, plate)
	
	local playerPed = GetPlayerPed(source)
	for _ = 1, 20 do
		Wait(0)
		SetPedIntoVehicle(playerPed, veh, -1)

		if GetVehiclePedIsIn(playerPed, false) == veh then
			break
		end
	end
	return netId
end)

lib.callback.register('00_garage:checkMoney', function(source)
	return GetMoney(source)
end)

RegisterNetEvent('impoundVeh:sv')
AddEventHandler('impoundVeh:sv', function(entity)
	local Vehicle = NetworkGetEntityFromNetworkId(entity)
	if DoesEntityExist(Vehicle) then
		DeleteEntity(Vehicle)
	end
end)