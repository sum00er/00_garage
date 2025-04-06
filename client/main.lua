isInMenu = false
isImpound = false
Current_garage, Current_job = nil, nil
data = {vehicles = {}}

lib.locale()

print("^200_garage by sum00er. https://discord.gg/pjuPHPrHnx")

RegisterNUICallback('fetchVehicleData', function(d, cb)
    local garage = isImpound and 0 or 1
    lib.callback('00_garage:getVehicles', false, function(vehicles)
        local NUIvehicleList = {}
        for n = 0, 1 do
            local n = tostring(n)
            for i = 1, #vehicles[n], 1 do
                local veh_type = GetVehicleType(vehicles[n][i].vehicle.model)
                if (not data.type and Config.specialType[veh_type]) or (data.type and veh_type ~= data.type) or (Current_job and Current_job ~= vehicles[n][i].job) or (not Current_job and vehicles[n][i].job) then
                    goto skip_this_veh
                end
                local vname = GetDisplayNameFromVehicleModel(vehicles[n][i].vehicle.model)
                local model = GetLabelText(vname)
                if model == 'NULL' then
                    model = vname
                end
                local parking = vehicles[n][i].parking
                if (tonumber(n) == garage and (garage == 0 or not Config.SeperateGarage)) or (Config.SeperateGarage and (parking == Current_garage or parking == locale('garage'))) then 
                    parking = '' 
                end

                table.insert(NUIvehicleList, {
                    name = model,
                    plate = vehicles[n][i].plate,
                    health = vehicles[n][i].vehicle.bodyHealth and math.floor(((vehicles[n][i].vehicle.bodyHealth + vehicles[n][i].vehicle.engineHealth)*100) / 2000) or '100',
                    fuel = vehicles[n][i].vehicle.fuelLevel and math.floor(vehicles[n][i].vehicle.fuelLevel) or '100',
                    status = n == '0' and 'impounded' or 'stored',
                    parking = parking,
                })
                data.vehicles[vehicles[n][i].plate] = vehicles[n][i].vehicle
                ::skip_this_veh::
            end
        end
        cb(json.encode(NUIvehicleList))
    end)
end)

RegisterNUICallback('function_na', function(d, cb)
    Config.notify(locale('function_na'))
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.Garages) do
        local BlipData = v.blip
        if BlipData?.Enable then
            local blip = AddBlipForCoord(BlipData.Coords)

            SetBlipSprite(blip, BlipData.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, BlipData.Scale)
            SetBlipColour(blip, BlipData.Colour)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(BlipData.Text)
            EndTextCommandSetBlipName(blip)
        end
    end
end)


for parking, v in pairs(Config.Garages) do
    for k, n in pairs(v.coords) do
        local point = lib.points.new({
            coords = n,
            distance = Config.DrawDistance,
        })
        function point:nearby()
            local my_job = GetJob()
            if not my_job then return end
            local isOpen, text = lib.isTextUIOpen()
            if (not IsPedInAnyVehicle(cache.ped, false) and k == 'StopPoint') or (v.job and v.job ~= my_job.name) or (v.grade and v.grade > my_job.grade) then
                if isOpen and text == locale(k, Config.ImpoundCost) then
                    Config.CloseUI()
                end
                return
            end
            local size = (k == 'StopPoint' and v.size) or Config.Markers[k].Size.x
            DrawMarker(Config.Markers[k].Type, n.x, n.y, n.z - 0.9, 0.0, 0.0,
                        0.0, 0, 0.0, 0.0, size, size,
                        Config.Markers[k].Size.z, Config.Markers[k].Color.r,
                        Config.Markers[k].Color.g, Config.Markers[k].Color.b, 255, false, true, 2, false,
                        false, false, false)
            if self.currentDistance <= size then
                if not isOpen then
                    Config.TextUI(locale(k, Config.ImpoundCost))
                end
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    if k == 'EntryPoint' then
                        OpenGarageMenu(false, v.SpawnPoint, parking, v.job_garage, v.type)
                    elseif k == 'StopPoint' then
                        StoreVehicle(parking, v.job_garage, v.type)
                    elseif k == 'GetOutPoint' then
                        OpenGarageMenu(true, v.SpawnPoint, parking, v.isJob and my_job.name, v.type)
                    end
                end
            elseif isOpen and text == locale(k, Config.ImpoundCost) then
                Config.CloseUI()
            end
        end
    end
end

function OpenGarageMenu(IsImpound, SpawnPoint, cgarage, job, vehType)
    isInMenu = true
    data.spawnPoint = SpawnPoint
    isImpound = IsImpound
    Current_garage = cgarage
    Current_job = job
    data.type = vehType
    local garage = 'stored'
    if isImpound then
        garage = 'impounded'
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "setVisible",
            data = {
                visible = true,
                locales = lib.getLocales(),
                garage = garage
            }
    })
end

exports('OpenGarageMenu', OpenGarageMenu)


RegisterNUICallback('spawnVehicle', function(d, cb)
    local spawnCoords = data.spawnPoint
    local plate = d.plate
    if isImpound then
        local money = lib.callback.await('00_garage:checkMoney', false)
        if money < Config.ImpoundCost then
            Config.notify(locale('missing_money'))
            CloseMenu()
            return
        end
    end
    local isOccupied = IsPositionOccupied(spawnCoords.x, spawnCoords.y, spawnCoords.z, 2.5, false, true, false, false, false, false, 0, false)
        if isOccupied or retrieving then
            if isOccupied then
                Config.notify(locale('veh_block'), 'error')
            end
            CloseMenu()
            return
        end
        retrieving = true
        if Config.trimPlate then
            plate = string.strtrim(plate)
        end
        local veh_property = data.vehicles[plate]
        local veh_type = GetVehicleType(veh_property.model)
        lib.callback('00_garage:spawnVehicle', false, function(netId)
            if netId then
                while not NetworkDoesNetworkIdExist(netId) do Wait(10) end
                local vehicle = NetworkGetEntityFromNetworkId(netId)
                while not DoesEntityExist(vehicle) do
                    vehicle = NetworkGetEntityFromNetworkId(netId)
                    Wait(10)
                end
                TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
                while not NetworkHasControlOfNetworkId(netId) do 
                    Wait(0)
                    NetworkRequestControlOfNetworkId(netId)
                end
                SetVehicleProperty(vehicle, veh_property)
                SetVehicleEngineOn(vehicle, true, true, true)
                if isImpound and Config.impoundState then
                    Entity(vehicle).state.fuel = Config.impoundState.fuel   --for ox_fuel

                    --or, use the following to use export of use other resource
                    -- exports[FuelResource]:SetFuel(vehicle, Config.impoundState.fuel)
                    SetVehicleBodyHealth(vehicle, Config.impoundState.bodyHealth)
                    SetVehicleEngineHealth(vehicle, Config.impoundState.engineHealth)
                else
                    Entity(vehicle).state.fuel = Config.impoundState.fuel   --for ox_fuel

                    --or, use the following to use export of use other resource
                    -- exports[FuelResource]:SetFuel(vehicle, veh_property.fuelLevel)
                    SetVehicleBodyHealth(vehicle, veh_property.bodyHealth)
                    SetVehicleEngineHealth(vehicle, veh_property.engineHealth)
                end

                TriggerServerEvent('00_garage:updateOwnedVehicle', 0, nil, veh_property, vehicle, isImpound, Current_job)
                
                Config.notify(locale('veh_released'))
            end
            retrieving = false
        end, plate, veh_property.model, veh_type, spawnCoords, data.spawnPoint.w, Current_garage)
        CloseMenu()
end)

function StoreVehicle(parking, job, garage_type)
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    local vehicleProps = GetVehicleProperty(vehicle)
    local veh_type = GetVehicleType(vehicleProps.model)
    if (not garage_type and Config.specialType[veh_type]) or (garage_type and veh_type ~= garage_type) then
        Config.notify(locale('vehtype_mismatch'))
        return 
    end

    lib.callback('00_garage:checkVehicleOwner', false, function(owner)
        if owner then
            local networkId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('impoundVeh:sv', networkId)
            TriggerServerEvent('00_garage:updateOwnedVehicle', 1, parking, vehicleProps, networkId, nil)
            Config.CloseUI()
        else
            Config.notify(locale('not_owning_veh'), 'error')
        end
    end, vehicleProps.plate, job)
end

exports('StoreVehicle', StoreVehicle)

function CloseMenu()
    isInMenu = false
    SetNuiFocus(false)
    SendNUIMessage({
        close = true
    })
end

RegisterNUICallback('close', function(data, cb)
    CloseMenu()
end)

RegisterNetEvent('00_garage:showNotification')
AddEventHandler('00_garage:showNotification', function(msg)
    Config.notify(msg)
end)

--from es_extended
local mismatchedTypes = {
    [`airtug`] = "automobile", -- trailer
    [`avisa`] = "submarine", -- boat
    [`blimp`] = "heli", -- plane
    [`blimp2`] = "heli", -- plane
    [`blimp3`] = "heli", -- plane
    [`caddy`] = "automobile", -- trailer
    [`caddy2`] = "automobile", -- trailer
    [`caddy3`] = "automobile", -- trailer
    [`chimera`] = "automobile", -- bike
    [`docktug`] = "automobile", -- trailer
    [`forklift`] = "automobile", -- trailer
    [`kosatka`] = "submarine", -- boat
    [`mower`] = "automobile", -- trailer
    [`policeb`] = "bike", -- automobile
    [`ripley`] = "automobile", -- trailer
    [`rrocket`] = "automobile", -- bike
    [`sadler`] = "automobile", -- trailer
    [`sadler2`] = "automobile", -- trailer
    [`scrap`] = "automobile", -- trailer
    [`slamtruck`] = "automobile", -- trailer
    [`Stryder`] = "automobile", -- bike
    [`submersible`] = "submarine", -- boat
    [`submersible2`] = "submarine", -- boat
    [`thruster`] = "heli", -- automobile
    [`towtruck`] = "automobile", -- trailer
    [`towtruck2`] = "automobile", -- trailer
    [`tractor`] = "automobile", -- trailer
    [`tractor2`] = "automobile", -- trailer
    [`tractor3`] = "automobile", -- trailer
    [`trailersmall2`] = "trailer", -- automobile
    [`utillitruck`] = "automobile", -- trailer
    [`utillitruck2`] = "automobile", -- trailer
    [`utillitruck3`] = "automobile", -- trailer
}

function GetVehicleType(model)
    model = type(model) == "string" and joaat(model) or model
    if not IsModelInCdimage(model) then
        return
    end
    if mismatchedTypes[model] then
        return mismatchedTypes[model]
    end

    local vehicleType = GetVehicleClassFromName(model)
    local types = {
        [8] = "bike",
        [11] = "trailer",
        [13] = "bike",
        [14] = "boat",
        [15] = "heli",
        [16] = "plane",
        [21] = "train",
    }

    return types[vehicleType] or "automobile"
end