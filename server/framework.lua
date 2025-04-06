if GetResourceState('es_extended') == 'started' then
    f = 'esx'
    sql_table = 'owned_vehicles'
    sql_id = 'owner'
    sql_stored = 'stored'
    sql_props = 'vehicle'
    sql_parking = 'parking'
elseif GetResourceState('qb-core') == 'started' then
    f = 'qb'
    sql_table = 'player_vehicles'
    sql_id = 'citizenid'
    sql_stored = 'state'
    sql_props = 'mods'
    sql_parking = 'garage'
    QBCore = exports['qb-core']:GetCoreObject()
end

function GetIdentifier(source)
    if f == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.identifier
    elseif f == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.citizenid
    end
end

function GetMoney(source)
    if f == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getMoney()
    elseif f == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.money['cash']
    end
end

function RemoveMoney(source, money)
    if f == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeMoney(money)
    elseif f == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.RemoveMoney('cash', money)
    end
end