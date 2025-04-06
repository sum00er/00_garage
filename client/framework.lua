local f

if GetResourceState('es_extended') == 'started' then
    f = 'esx'
elseif GetResourceState('qb-core') == 'started' then
    f = 'qb'
    QBCore = exports['qb-core']:GetCoreObject()
end


print('framework is '..f)


function GetJob()
    if f == 'esx' then
        return ESX.PlayerData?.job
    elseif f == 'qb' then
        local xPlayer = QBCore.Functions.GetPlayerData()
        return xPlayer?.job
    end
end

function GetVehicleProperty(vehicle)
    if f == 'esx' then
        return ESX.Game.GetVehicleProperties(vehicle)
    elseif f == 'qb' then
        return QBCore.Functions.GetVehicleProperties(vehicle)
    end
end

function SetVehicleProperty(vehicle, props)
    if f == 'esx' then
        return ESX.Game.SetVehicleProperties(vehicle, props)
    elseif f == 'qb' then
        return QBCore.Functions.SetVehicleProperties(vehicle, props)
    end
end