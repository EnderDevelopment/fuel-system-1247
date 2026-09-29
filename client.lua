local ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local fuelLevel = GetVehicleFuelLevel(vehicle)
            if fuelLevel > 0 then
                SetVehicleFuelLevel(vehicle, fuelLevel - Config.FuelConsumptionRate)
            else
                SetVehicleEngineOn(vehicle, false, true, true)
            end
        end
    end
end)

RegisterNetEvent('fuel:updateFuel')
AddEventHandler('fuel:updateFuel', function(plate, fuel)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if GetVehicleNumberPlateText(vehicle) == plate then
        SetVehicleFuelLevel(vehicle, fuel)
    end
end)