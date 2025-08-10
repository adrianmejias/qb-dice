local Translations = {
    error = {
        usage = 'Usage: /dice <citizenid1> <citizenid2> ...',
        in_game = 'You are already in a dice game.',
        target_in_game = 'One of the specified players is already in a dice game.',
        player_not_found = 'Could not find one of the specified players (%{citizenid}).',
        need_two = 'Need at least 2 players.',
        no_game = 'No active dice game.',
        not_turn = 'It is not your turn.'
    },
    success = {
        game_started = 'Dice game started. Stay near the spot!',
        you_joined = 'You joined a dice game. Stay near the spot!'
    },
    info = {
        player_left = '%{name} left the dice game.',
        game_cancelled = 'Dice game cancelled.',
        started_by = 'Dice game started by %{name}',
        turn_notice = "It's %{name}'s turn.",
        rolled = '%{name} rolled %{total} (%{d1} + %{d2})'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Translations
