local Config = Config
local QBCore = exports['qb-core']:GetCoreObject()

local activeGameId = nil
local gameOrigin = nil
local scoreboard = {}
local turnIndex = 1
local startedBy = nil
local myCitizenId = nil

local function PlayCrouch()
    if not Config.Anim.dict then return end
    RequestAnimDict(Config.Anim.dict)
    while not HasAnimDictLoaded(Config.Anim.dict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), Config.Anim.dict, Config.Anim.name, 2.0, 2.0, -1, 1, 0, false, false, false)
end

local function PlayRollAnim()
    if not Config.Anim.diceDict then return end
    RequestAnimDict(Config.Anim.diceDict)
    while not HasAnimDictLoaded(Config.Anim.diceDict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), Config.Anim.diceDict, Config.Anim.diceName, 2.0, 2.0, 2000, 0, 0, false, false, false)
end

RegisterNetEvent('qb-dice:client:startGame', function(gameId, origin, youCitizenId)
    activeGameId = gameId
    gameOrigin = vector3(origin.x, origin.y, origin.z)
    myCitizenId = youCitizenId
    PlayCrouch()
end)

RegisterNetEvent('qb-dice:client:updateScoreboard', function(board, curTurn, origin, started)
    scoreboard = board
    turnIndex = curTurn
    startedBy = started
    SendNUIMessage({
        action = 'dice:update',
        board = scoreboard,
        turnIndex = turnIndex,
        startedBy = startedBy,
        youCitizenId = myCitizenId
    })
end)

RegisterNetEvent('qb-dice:client:playRollAnim', function(src)
    if GetPlayerServerId(PlayerId()) == src then
        PlayRollAnim()
    end
end)

RegisterNetEvent('qb-dice:client:cleanup', function()
    activeGameId = nil
    gameOrigin = nil
    scoreboard = {}
    turnIndex = 1
    startedBy = nil
    myCitizenId = nil
    ClearPedTasks(PlayerPedId())
    SendNUIMessage({ action = 'dice:hide' })
end)

-- Simple roll key (E) if in game & your turn; or command /roll
CreateThread(function()
    while true do
        if activeGameId then
            Wait(0)
            if IsControlJustReleased(0, 38) then -- E to roll
                TriggerServerEvent('qb-dice:server:roll')
            end
        else
            Wait(500)
        end
    end
end)

RegisterCommand('roll', function()
    if activeGameId then
        TriggerServerEvent('qb-dice:server:roll')
    end
end)

-- NUI callbacks
RegisterNUICallback('roll', function(_, cb)
    if activeGameId then
        TriggerServerEvent('qb-dice:server:roll')
    end
    cb({ ok = true })
end)
