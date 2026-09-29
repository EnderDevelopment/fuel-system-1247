local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('fuel:getFuel', function(source, cb, plate)
    MySQL.Async.fetchScalar('SELECT fuel FROM vehicle_fuel WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(fuel)
        if fuel then
            cb(fuel)
        else
            MySQL.Async.execute('INSERT INTO vehicle_fuel (plate, fuel) VALUES (@plate, @fuel)', {
                ['@plate'] = plate,
                ['@fuel'] = Config.MaxFuel
            }, function()
                cb(Config.MaxFuel)
            end)
        end
    end)
end)

RegisterNetEvent('fuel:addFuel')
AddEventHandler('fuel:addFuel', function(plate, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local totalCost = amount * Config.FuelPrice
    if xPlayer.getMoney() >= totalCost then
        xPlayer.removeMoney(totalCost)
        MySQL.Async.fetchScalar('SELECT fuel FROM vehicle_fuel WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(currentFuel)
            local newFuel = math.min(currentFuel + amount, Config.MaxFuel)
            MySQL.Async.execute('UPDATE vehicle_fuel SET fuel = @fuel WHERE plate = @plate', {
                ['@fuel'] = newFuel,
                ['@plate'] = plate
            }, function()
                TriggerClientEvent('fuel:updateFuel', xPlayer.source, plate, newFuel)
            end)
        end)
    else
        TriggerClientEvent('esx:showNotification', source, 'Not enough money')
    end
end)