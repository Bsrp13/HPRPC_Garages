
HPRPCMenu.CreateMenu("VehicleSpawner", "Garage")
HPRPCMenu.SetSubTitle("VehicleSpawner", "VEHICLE_NAME")

function requestAcesForList(list)
    local response = nil

    TriggerServerEvent('filterForAceAllowed', list)
    RegisterNetEvent("hereAceAllowedList")
    local handler = AddEventHandler("hereAceAllowedList", function(returnedList)
        response = returnedList
    end)

    while response == nil do
        Citizen.Wait(0)
    end

    RemoveEventHandler(handler)

    return response
end

-- CHECK AREA

ShowNotification = function(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end

		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

GetVehiclesInArea = function (coords, area)
    local vehicles       = GetVehicles()
    local vehiclesInArea = {}

    for i=1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

        if distance <= area then
            table.insert(vehiclesInArea, vehicles[i])
        end
    end

    return vehiclesInArea
end

IsSpawnPointClear = function(coords, radius)
    local vehicles = GetVehiclesInArea(coords, radius)

    return #vehicles == 0
end





function DrawText3Ds(coords, text)
    local x,y,z = table.unpack(coords)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z+1.0)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end


function spawnVehicle(spots, model)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(1)
    end
    local foundSpot = nil
    for k,v in pairs(spots) do
        if IsSpawnPointClear(v, 3.0) then
            foundSpot = v
            break
        end
    end

    if foundSpot then
        ShowNotification('~g~ Spawned')

        local vehicle = CreateVehicle(model, foundSpot, foundSpot.w, true, false)

        if teleportPlayerIntoCar then
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        end

    else
        ShowNotification('~r~ No Spawn Point Available!')
    end
end


function openMenu(k)
    print(k)
    local hasSpawned = false
    HPRPCMenu.OpenMenu("VehicleSpawner")
    HPRPCMenu.SetSubTitle("VehicleSpawner", k)
    print(HPRPCMenu.IsMenuOpened('VehicleSpawner'))
    FreezeEntityPosition(PlayerPedId(), true)

    local actualList = requestAcesForList(locations[k].vehicle_catagories)

    while HPRPCMenu.IsMenuOpened('VehicleSpawner') do


        print(json.encode(actualList))

        if #actualList == 0 then
            while HPRPCMenu.IsMenuOpened('VehicleSpawner') do
                HPRPCMenu.Button('EMPTY', 'EMPTY')
                HPRPCMenu.Display()
                Citizen.Wait(0)
            end
        end

        for k2,v2 in pairs(actualList) do
            
            if HPRPCMenu.Button(v2, '>') then
                HPRPCMenu.CloseMenu('VehicleSpawner')
                Citizen.Wait(100)
                HPRPCMenu.OpenMenu('VehicleSpawner')
                while HPRPCMenu.IsMenuOpened('VehicleSpawner') do
                    for k3,v3 in pairs(vehicle_list[v2].cars) do
                        if HPRPCMenu.Button(v3[1], 'Spawn') then
                            spawnVehicle(locations[k].parking_spots, v3[2])
                            hasSpawned = true
                            HPRPCMenu.CloseMenu('VehicleSpawner')
                        end
                    end

                    HPRPCMenu.Display()
                    Citizen.Wait(0)
                end
                if not hasSpawned then
                    HPRPCMenu.OpenMenu('VehicleSpawner')
                end
            end
        end

        HPRPCMenu.Display()
        Citizen.Wait(0)
    end
    FreezeEntityPosition(PlayerPedId(), false)


end
local function DisplayNotification(msg, thisFrame)
    AddTextEntry('showNotification2', msg)

    if thisFrame then
        DisplayHelpTextThisFrame('showNotification2', false)
    else
        BeginTextCommandDisplayHelp('showNotification2')
        EndTextCommandDisplayHelp(0, false, 0, -1)
    end
end


Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ourCoords = GetEntityCoords(PlayerPedId())
        for k,v in pairs(locations) do
            if #(v.coords - ourCoords) <= blipRenderDistance then
                sleep = 0
                DrawMarker(v.MarkerId,v.coords.x,v.coords.y,v.coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.MarkerSize.x, v.MarkerSize.y, v.MarkerSize.z, v.Color.x, v.Color.y, v.Color.z, 100, false, true, 2, false, false, false, false)

                if #(v.coords - ourCoords) <= interactDistance then
                    sleep = 0
                    DisplayNotification('~w~Press ~r~E~w~ to open the garage!', true) -- change the text here to whatever you want
                    DrawText3Ds(v.coords, 'Garage')

                    if IsControlJustReleased(0, 38) then
                        openMenu(k)
                    end

                end

            end
        end
        Citizen.Wait(sleep)
    end
end)