
RegisterNetEvent("filterForAceAllowed")
AddEventHandler("filterForAceAllowed", function(list)
    local src = source

    print(src)

    toReturn = {}

    for k,v in pairs(list) do
        print(json.encode(v))
        for k2,v2 in pairs(vehicle_list[list[k]].acePerm) do
            if IsPlayerAceAllowed(src, v2) then
                print("Allowed Ace: "..v2)
                toReturn[k] = v
            else
                print("Not Allowed Ace: "..v2)
            end
        end
    end

    TriggerClientEvent('hereAceAllowedList', src, toReturn)
end)
