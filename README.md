## qb-dice

Simple street dice mini‑game resource for QBCore (FiveM) with a clean Vue 3 + Tailwind UI scoreboard panel. Players start a quick dice session with nearby friends using their citizen IDs; turn order, rolls, and scores are synced server‑side. Leaving the play radius or disconnecting auto‑removes a player and may cancel the game.

UNTESTED! PLEASE DO NOT USE RIGHT NOW!

### Features
- /dice command to start a multiplayer dice game (up to configurable max players)
- Turn‑based two‑dice rolls (2d6) accumulating total score
- Live NUI panel (Vue 3 + Tailwind) showing: starter, turn indicator, last roll, running scores
- Press E (in world) or click Roll button when it's your turn
- Automatic removal if a player walks too far from origin or disconnects
- Locale / translation support (QBCore Locale system)
- Lightweight configurable animations (crouch idle + roll) – easy to swap
- Server export for integration (fetch active game for a player)

---

## Requirements
| Component | Notes |
|-----------|-------|
| FiveM Artifact (fxserver) | fx_version 'cerulean' |
| QBCore Framework | Provide `qb-core` for locale + notifications |
| Node.js 18+ (dev only) | To rebuild the UI via Vite |
| Yarn / npm / pnpm (one) | Dependency install for UI |

The distributed `html/` folder is already built. Rebuilding is only needed if you change the UI under `src/`.

---

## Installation (Quick)
1. Clone or download into your resources folder, e.g. `resources/[qb]/qb-dice`.
2. (Optional) Adjust settings in `config.lua`.
3. Ensure it after `qb-core` in your server cfg:
   ```cfg
   ensure qb-core
   ensure qb-dice
   ```
4. Restart the server or run `refresh` + `ensure qb-dice`.

### Updating
Replace the folder (keep or re‑apply any local changes to `config.lua` or custom locales), then restart the resource.

---

## Usage
Start a game including yourself plus target players (by citizenid):
```
/dice <citizenid1> <citizenid2> ...
```
Example:
```
/dice QBC12345 QBC67890
```
Minimum: 2 players (you + 1). Max: `Config.MaxPlayers` (default 4). The origin point is where the starter stands.

Rolling:
* When it's your turn: Press E or use the Roll button in the NUI panel, or type `/roll`.

Leaving the radius (`Config.MaxDistanceFromOrigin`) removes you; if the starter leaves or fewer than 2 players remain, the game ends.

---

## Configuration (`config.lua`)
| Key | Default | Description |
|-----|---------|-------------|
| `MaxPlayers` | 4 | Maximum simultaneous players in one game |
| `MaxDistanceFromOrigin` | 6.0 | Distance in meters before auto removal |
| `DistanceCheckInterval` | 3000 ms | Interval for distance enforcement |
| `ScoreboardTick` | 2000 ms | (Reserved) scoreboard push interval |
| `Anim.dict` / `Anim.name` | placeholders | Idle / crouch style anim while in game |
| `Anim.diceDict` / `Anim.diceName` | placeholders | Roll animation |
| `Messages` | (legacy) | Kept for reference; active strings now via locales |
| `Command` | `dice` | Primary start command name |

Change animations by supplying any valid animation dictionary/name pair.

---

## Localization
Files in `locales/*.lua` are auto loaded (English included). To add another language:
1. Copy `locales/en.lua` to e.g. `locales/es.lua`.
2. Translate the phrases.
3. Ensure your server locale handling activates the new language (standard QBCore Locale flow).

Placeholders follow `%{name}` style (QBCore locale interpolation).

---

## UI / Frontend Development
Source lives in `src/` and is built to `html/` via Vite.

Development (hot reload):
```bash
npm install   # or pnpm install / yarn
npm run dev   # serves from src/ (you can open in browser for UI tweaking)
```

Production build (writes to `html/`):
```bash
npm run build
```

Do NOT rename `html/index.html` or the resource manifest references.

### Tailwind
Using Tailwind (v4 via `@tailwindcss/vite` plugin). Adjust styling in `src/css/app.css`.

---

## Server / Client Events
Client receives:
- `qb-dice:client:startGame (gameId, origin, youCitizenId)` – Initialize local state + play idle anim.
- `qb-dice:client:updateScoreboard (board, turnIndex, origin, startedBy)` – Refresh UI.
- `qb-dice:client:playRollAnim (src)` – Triggers roll animation for the rolling player.
- `qb-dice:client:cleanup` – Reset state/animations + hide UI.

Client triggers:
- `qb-dice:server:roll` – Attempt to roll (validated server‑side turn order).

Server internal helpers broadcast QBCore notifications for feedback.

---

## Export
```lua
local game = exports['qb-dice']:GetPlayerGame(citizenid)
if game then
	-- game.id, game.origin (vector3), game.players (array), game.turnIndex, game.startedBy
end
```
Each `game.players` entry: `{ src, citizenid, name, score, lastRoll }`.

---

## Integration Ideas
- Extend with wagers / item stakes before game begins.
- Persist match history or leaderboard.
- Add /spectate scoreboard mode for nearby players.
- Custom per‑roll animations or particle effects.

---

## Security / Anti‑Cheat Notes
All authoritative logic (turn order, dice result, score accumulation, distance enforcement) runs server‑side. Clients merely request rolls; the server validates. If you integrate with an anti‑cheat, keep animation dictionary usage whitelisted.

---

## Troubleshooting
| Issue | Likely Cause | Fix |
|-------|--------------|-----|
| Command gives usage error | Not enough arguments | Provide at least one other citizenid |
| Player not added | Wrong citizenid | Verify with `/players` or similar admin list |
| UI not showing | NUI blocked / message not received | Check F8 console for errors; rebuild UI if modified |
| Game ends unexpectedly | Starter left or players < 2 | This is intended behavior |

---

## Roadmap (Potential)
- Configurable win condition (e.g., first to X points, fixed round count)
- Slash UI toggle command
- Dice roll 3D props instead of animations
- Improved dedicated dice animations

---

## Contributing
PRs & issues welcome. Keep style consistent and avoid large rewrites without discussion.

Dev tips:
- Avoid blocking loops; use existing intervals.
- Keep client state minimal; server stays authoritative.

---

## Versioning
Current version: 1.3.0 (see `fxmanifest.lua`). Follow semantic versioning (MAJOR.MINOR.PATCH) when contributing.

---

## License
This project is licensed under the GNU General Public License v3.0 (GPL-3.0). You may copy, modify, and redistribute the code provided that:

1. Source remains available (must provide corresponding source when distributing binaries or modified versions).
2. Derivative works are also licensed under GPL-3.0 (strong copyleft – no relicensing to a proprietary license).
3. You include a copy of the GPL-3.0 license and preserve notices / disclaimers.

There is NO WARRANTY (see full text for details). For the complete legal terms, read the `LICENSE` file in this repository or visit: https://www.gnu.org/licenses/gpl-3.0.html

If you contribute, you agree to license your contributions under the same GPL-3.0 terms. For alternative licensing discussions (dual-license, etc.), open an issue first.

Copyright (C) 2025 AbstractCoding

---

## Credits
Author: AbstractCoding
Framework: QBCore
UI: Vue 3 + Tailwind CSS

Enjoy and roll responsibly.
