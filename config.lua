Config = {}

-- Maximum players allowed in a dice game
Config.MaxPlayers = 4

-- How far (in meters) a player can move from the origin before being removed
Config.MaxDistanceFromOrigin = 6.0

-- Time (ms) between distance checks
Config.DistanceCheckInterval = 3000

-- Time (ms) between scoreboard refresh pushes
Config.ScoreboardTick = 2000

-- Animation dictionary and names
Config.Anim = {
    dict = 'amb@world_human_bum_slumped@male@laying_on_left_side@base', -- placeholder idle crouch-ish anim; can be replaced with better crouch dice anim
    name = 'base',
    diceDict = 'anim@mp_player_intcelebrationmale@wank', -- placeholder for dice roll anim
    diceName = 'wank'
}

-- Language / messages
Config.Messages = {
    NotEnoughArgs = 'Usage: /dice <citizenid1> <citizenid2> ...',
    GameExists = 'You are already in a dice game.',
    TargetInGame = 'One of the specified players is already in a dice game.',
    PlayerNotFound = 'Could not find one of the specified players.',
    GameStarted = 'Dice game started. Stay near the spot!',
    YouJoined = 'You joined a dice game. Stay near the spot!',
    PlayerLeft = '%s left the dice game.',
    YouLeft = 'You left the dice game.',
    GameCancelled = 'Dice game cancelled.',
    Rolled = '%s rolled %d (%d + %d)',
    NotYourTurn = 'It is not your turn.',
    TurnNotice = "It's %s's turn.",
    GameFull = 'Dice game is full.',
    GameDoesNotExist = 'No active dice game.',
    AlreadyInGame = 'You are already in a dice game.',
    StartedBy = 'Dice game started by %s',
}

-- Command name
Config.Command = 'dice'

return Config
