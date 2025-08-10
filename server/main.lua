local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config

local ActiveGames = {}
local PlayerGame = {} -- citizenid -> gameId
local GameIdCounter = 0

local function NewGameId()
    GameIdCounter = GameIdCounter + 1
    return GameIdCounter
end

local function Notify(src, msg, msgType)
    TriggerClientEvent('QBCore:Notify', src, msg, msgType or 'primary')
end

local function BroadcastRaw(game, msg)
    for _, p in ipairs(game.players) do
        if p.src then
            Notify(p.src, msg, 'primary')
        end
    end
end

local function PushScoreboard(game)
    local board = {}
    for _, p in ipairs(game.players) do
        board[#board+1] = {
            name = p.name,
            citizenid = p.citizenid,
            score = p.score or 0,
            lastRoll = p.lastRoll or nil,
        }
    end
    for _, p in ipairs(game.players) do
        TriggerClientEvent('qb-dice:client:updateScoreboard', p.src, board, game.turnIndex, game.origin, game.startedBy)
    end
end

local function EndGame(game, reasonMsg)
    if not game or game.ended then return end
    game.ended = true
    for _, p in ipairs(game.players) do
        PlayerGame[p.citizenid] = nil
        if p.src then
            if reasonMsg then Notify(p.src, reasonMsg, 'error') end
            TriggerClientEvent('qb-dice:client:cleanup', p.src)
        end
    end
    ActiveGames[game.id] = nil
end

local function RemovePlayer(game, citizenid, reason)
    if not game or game.ended then return end
    local removedStarter = (game.startedByCitizenId == citizenid)
    for i, p in ipairs(game.players) do
        if p.citizenid == citizenid then
            table.remove(game.players, i)
            PlayerGame[citizenid] = nil
            if p.src then
                Notify(p.src, Lang:t('info.player_left', { name = p.name }), 'error')
                TriggerClientEvent('qb-dice:client:cleanup', p.src)
            end
            BroadcastRaw(game, Lang:t('info.player_left', { name = p.name }))
            break
        end
    end
    if removedStarter or #game.players < 2 then
        EndGame(game, Lang:t('info.game_cancelled'))
        return
    end
    if game.turnIndex > #game.players then
        game.turnIndex = 1
    end
    PushScoreboard(game)
end

local function NextTurn(game)
    if not game or game.ended then return end
    game.turnIndex = game.turnIndex + 1
    if game.turnIndex > #game.players then
        game.turnIndex = 1
    end
    local turnPlayer = game.players[game.turnIndex]
    BroadcastRaw(game, Lang:t('info.turn_notice', { name = turnPlayer.name }))
    PushScoreboard(game)
end

RegisterCommand(Config.Command, function(src, args)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    if PlayerGame[citizenid] then
    Notify(src, Lang:t('error.in_game'), 'error')
        return
    end
    if #args < 1 then
    Notify(src, Lang:t('error.usage'), 'error')
        return
    end

    local targets = {citizenid}
    local added = {}
    added[citizenid] = true

    for _, arg in ipairs(args) do
        local found = nil
        for _, ply in pairs(QBCore.Functions.GetQBPlayers()) do
            if ply.PlayerData.citizenid == arg then
                found = ply
                break
            end
        end
        if not found then
            Notify(src, Lang:t('error.player_not_found', { citizenid = arg }), 'error')
            return
        end
        local tcid = found.PlayerData.citizenid
        if PlayerGame[tcid] then
            Notify(src, Lang:t('error.target_in_game') .. ' ('..arg..')', 'error')
            return
        end
        if not added[tcid] then
            targets[#targets+1] = tcid
            added[tcid] = true
        end
        if #targets >= Config.MaxPlayers then break end
    end

    if #targets < 2 then
    Notify(src, Lang:t('error.need_two'), 'error')
        return
    end

    -- Create game
    local gameId = NewGameId()
    local origin = GetEntityCoords(GetPlayerPed(src))
    local game = {
        id = gameId,
        origin = origin,
        players = {},
        turnIndex = 1,
        startedBy = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        startedByCitizenId = citizenid,
    }

    for _, cid in ipairs(targets) do
        for _, ply in pairs(QBCore.Functions.GetQBPlayers()) do
            if ply.PlayerData.citizenid == cid then
                local fullname = ply.PlayerData.charinfo.firstname .. ' ' .. ply.PlayerData.charinfo.lastname
                local entry = {
                    src = ply.PlayerData.source,
                    citizenid = cid,
                    name = fullname,
                    score = 0,
                }
                game.players[#game.players+1] = entry
                PlayerGame[cid] = gameId
                Notify(entry.src, cid == citizenid and Lang:t('success.game_started') or Lang:t('success.you_joined'), 'success')
                TriggerClientEvent('qb-dice:client:startGame', entry.src, gameId, origin, cid)
            end
        end
    end

    ActiveGames[gameId] = game
    BroadcastRaw(game, Lang:t('info.started_by', { name = game.startedBy }))
    local firstPlayer = game.players[game.turnIndex]
    BroadcastRaw(game, Lang:t('info.turn_notice', { name = firstPlayer.name }))
    PushScoreboard(game)
end)

RegisterNetEvent('qb-dice:server:roll', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    local gameId = PlayerGame[citizenid]
    if not gameId then
    Notify(src, Lang:t('error.no_game'), 'error')
        return
    end
    local game = ActiveGames[gameId]
    if not game or game.ended then
    Notify(src, Lang:t('error.no_game'), 'error')
        return
    end
    local current = game.players[game.turnIndex]
    if not current or current.citizenid ~= citizenid then
    Notify(src, Lang:t('error.not_turn'), 'error')
        return
    end
    local d1 = math.random(1,6)
    local d2 = math.random(1,6)
    local total = d1 + d2
    current.score = current.score + total
    current.lastRoll = total
    BroadcastRaw(game, Lang:t('info.rolled', { name = current.name, total = total, d1 = d1, d2 = d2 }))
    TriggerClientEvent('qb-dice:client:playRollAnim', -1, src) -- optional broadcast
    PushScoreboard(game)
    NextTurn(game)
end)

-- Distance / presence monitoring
CreateThread(function()
    while true do
        Wait(Config.DistanceCheckInterval)
        for id, game in pairs(ActiveGames) do
            if not game.ended then
                local toRemove = {}
                for _, p in ipairs(game.players) do
                    if p.src then
                        local ped = GetPlayerPed(p.src)
                        if ped ~= 0 then
                            local coords = GetEntityCoords(ped)
                            local dist = #(coords - game.origin)
                            if dist > Config.MaxDistanceFromOrigin then
                                toRemove[#toRemove+1] = p.citizenid
                            end
                        else
                            toRemove[#toRemove+1] = p.citizenid
                        end
                    else
                        toRemove[#toRemove+1] = p.citizenid
                    end
                end
                for _, cid in ipairs(toRemove) do
                    RemovePlayer(game, cid, 'left area')
                    if game.ended then break end
                end
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    local gameId = PlayerGame[citizenid]
    if gameId then
        local game = ActiveGames[gameId]
        RemovePlayer(game, citizenid, 'player dropped')
    end
end)

-- Exports for potential future integration
exports('GetPlayerGame', function(citizenid)
    local gid = PlayerGame[citizenid]
    if gid then
        return ActiveGames[gid]
    end
    return nil
end)
