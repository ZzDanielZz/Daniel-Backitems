Core = exports[Config.Framework]:GetCoreObject()

local CurrentBackItems = {}
local TempBackItems = {}
local checking = false
local currentWeapon = nil
local s = {}

Debug = function(...)
    if Config.Debug then
        print(...)
    end
end

isWearingRestrictedBag = function()
    local ped = PlayerPedId()
    local currentBag = GetPedDrawableVariation(ped, 5)
    return Config.restrictedBags[currentBag] == true
end

isWearingRestrictedUndershirt = function()
    local ped = PlayerPedId()
    local currentUndershirt = GetPedDrawableVariation(ped, 8)
    return Config.restrictedUndershirts[currentUndershirt] == true
end

shouldRemoveBackItems = function()
    return isWearingRestrictedBag() or isWearingRestrictedUndershirt()
end

-- AddEventHandler("onResourceStart", function(resourceName)
-- 	if (GetCurrentResourceName() ~= resourceName) then return end
--     BackLoop()
-- end)

AddEventHandler("onResourceStop", function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    resetItems()
end)

RegisterNetEvent(Config.PlayerUnload, function()
    resetItems()
end)

RegisterNetEvent(Config.PlayerLoad, function()
    Debug("Player Has Been Loaded By " .. GetCurrentResourceName())
    checking = true
    BackLoop()
end)

resetItems = function()
    removeAllBackItems()
    CurrentBackItems = {}
    TempBackItems = {}
    currentWeapon = nil
    s = {}
    checking = false
end

BackLoop = function()
    Debug("[Daniel - Backitems]: Starting Loop")
    Citizen.CreateThread(function()
        while true do
            if checking then

                local player = Core.Functions.GetPlayerData()
                local retryCount = 0
                while player == nil and retryCount < 10 do
                    player = Core.Functions.GetPlayerData()
                    retryCount = retryCount + 1
                    Wait(500)
                end

                if player == nil then
                    Debug("[Daniel - Backitems]: Failed to retrieve player data after retries")
                else
                    if shouldRemoveBackItems() then
                        removeAllBackItems()
                    else
                        for i = 1, Config.PlayerSlots do
                            s[i] = player.items[i]
                        end
                        check()
                    end
                end
            end

            Wait(1000)
        end
    end)
end

check = function()
    for i = 1, Config.PlayerSlots do
        if s[i] ~= nil then
            local name = s[i].name
            if Config.BackItems[name] then
                if name ~= currentWeapon then
                    createBackItem(name)
                end
            end
        end
    end

    for k,v in pairs(CurrentBackItems) do 
        local hasItem = false
        for j = 1, Config.PlayerSlots do
            if s[j] ~= nil then
                local name = s[j].name
                if name == k then 
                    hasItem = true
                end
            end
        end
        if not hasItem then 
            removeBackItem(k)
        end
    end
end

createBackItem = function(item)
    if not CurrentBackItems[item] and not shouldRemoveBackItems() then
        if Config.BackItems[item] then
            local i = Config.BackItems[item]
            local model = i["model"]
            local ped = PlayerPedId()
            local bone = GetPedBoneIndex(ped, i["back_bone"])
            
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
            SetModelAsNoLongerNeeded(model)
            
            CurrentBackItems[item] = CreateObject(GetHashKey(model), 1.0, 1.0, 1.0, true, true, false)
            local y = i["y"]  
            if Core.Functions.GetPlayerData().charinfo.gender == 1 then y = y + 0.035 end
            AttachEntityToEntity(CurrentBackItems[item], ped, bone, i["x"], y, i["z"], i["x_rotation"], i["y_rotation"], i["z_rotation"], 0, 1, 0, 1, 0, 1)
            
            SetEntityCompletelyDisableCollision(CurrentBackItems[item], false, true)
        end
    end
end

removeBackItem = function(item)
    if CurrentBackItems[item] then
        DeleteEntity(CurrentBackItems[item])
        CurrentBackItems[item] = nil
    end
end

removeAllBackItems = function()
    for k,v in pairs(CurrentBackItems) do 
        removeBackItem(k)
    end
end

if Config.UsingQBWeapons then
    RegisterNetEvent('weapons:client:SetCurrentWeapon', function(weap, shootbool)
        if weap == nil then
            if currentWeapon then
                createBackItem(currentWeapon)
            end
            currentWeapon = nil
        else
            if currentWeapon ~= nil then  
                createBackItem(currentWeapon)
            end
            currentWeapon = tostring(weap.name)
            createBackItem(currentWeapon)
        end
    end)
end