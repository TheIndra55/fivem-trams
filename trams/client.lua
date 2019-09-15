-- table containing all trains which are known
local trains = {}
local inTram = false

local currentNode = nil

-- list of stations and their node ids
-- you probably don't have to modify this except when you are renaming stations
local stations = {
    { node = 179,  name = "Strawberry",      },
    { node = 271,  name = "Puerto Del Sol",  },
    { node = 388,  name = "LSIA Parking",    },
    { node = 434,  name = "LSIA Terminal 4", },
    { node = 530,  name = "LSIA Terminal 4", },
    { node = 578,  name = "LSIA Parking",    },
    { node = 689,  name = "Puerto Del Sol",  },
    { node = 782,  name = "Strawberry",      },
    { node = 1078, name = "Burton",          },
    { node = 1162, name = "Portola Drive",   },
    { node = 1233, name = "Del Perro",       },
    { node = 1331, name = "Little Seoul",    },
    { node = 1397, name = "Pillbox South",   },
    { node = 1522, name = "Davis",           },
    { node = 1649, name = "Davis",           },
    { node = 1791, name = "Pillbox South",   },
    { node = 1869, name = "Little Seoul",    },
    { node = 1977, name = "Del Perro",       },
    { node = 2066, name = "Portola Drive",   },
    { node = 2153, name = "Burton",          },
    -- this last station is here because this track ends at 2245 and first next station is at 179
    { node = 2246, name = "Strawberry"       }
}

local doors = {left = {0, 2}, right = {1, 3}}

Citizen.CreateThread(function()
    -- if enabled this will tell gta to spawn trains naturally
    if config.enableTrains or config.enableTrams then
        if config.enableTrains then SwitchTrainTrack(0, true) end

        if config.enableTrams then SwitchTrainTrack(3, true) end

        N_0x21973bbf8d17edfa(0, 120000) -- found by Disquse
        SetRandomTrains(1)
    end

    AddTextEntry("NEXT_STATION_NOTIFICATION", config.text)
end)

-- fetch list of trains every sec to improve performance
CreateThread(function()
    while true do
        Wait(1000)

        local player = PlayerPedId()
        local coords = GetEntityCoords(player)

        -- add all known trains to table
        trains = GetTrams(coords)

        -- get closest train
        if #trains >= 1 then
            local train = trains[1][1]

            if train ~= nil then
                currentNode = GetTrainCurrentTrackNode(train)
            else
                currentNode = nil
            end
        end

        inTram = IsPedInAnyTrain(player)
    end
end)

function drawThere(coords, text)
    SetDrawOrigin(coords)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)

    ClearDrawOrigin()
end

CreateThread(function()
    while true do
        Wait(0)

        if inTram and currentNode ~= nil then
            local nextst = "Unknown"

            for _, station in ipairs(stations) do
                -- check if train current node is before next station
                if currentNode < station.node then
                    nextst = station.name

                    break
                end
            end

            BeginTextCommandDisplayHelp("NEXT_STATION_NOTIFICATION")
            AddTextComponentSubstringPlayerName(nextst)
            EndTextCommandDisplayHelp(0, 0, 1, -1)
        end
    end
end)

CreateThread(function()
    if not config.closeDoors then return end

    while true do
        Wait(0)

        -- train doors in gta automatically open when closed so set it closed every tick if driving
        for _, train in pairs(trains) do
            -- only do for close trains
            if train[2] < 200 then
                if train[3] --[[ speed ]] > 0.5 then
                    SetVehicleDoorsShut(train[1], true)
                elseif config.closeDoorsAtStations then
                    -- trams in gta are two "metrotrains" which both face another direction so doors are at other side
                    -- if the current train entity has no second carriage we can assume it's the back train etc
                    if DoesEntityExist(GetTrainCarriage(train[1], 1)) then
                        -- close right
                        -- drawThere(GetEntityCoords(train[1]), "right")
                        shutSide(train[1], "right")
                    else
                        -- drawThere(GetEntityCoords(train[1]), "left")
                        shutSide(train[1], "left")
                    end
                end
            end
        end

        -- DrawBox(GetEntityCoords(trains[1][1]) - 1, GetEntityCoords(trains[1][1]) + 1, 255, 255, 255, 100)
    end
end)

function shutSide(vehicle, side)
    if doors[side] then
        for _, door in pairs(doors[side]) do
            SetVehicleDoorShut(vehicle, door, true)
        end
    end
end

function compareCoords(a, b) return a[2] < b[2] end

function GetTrams(coords)
    local trams = {}

    for vehicle in EnumerateVehicles() do
        local distance = #(GetEntityCoords(vehicle) - coords)

        if distance <= 100 and GetEntityModel(vehicle) == `metrotrain` then
            table.insert(trams, {vehicle, distance, GetEntitySpeed(vehicle)})
        end
    end

    -- sort by distance
    table.sort(trams, compareCoords)

    return trams
end
