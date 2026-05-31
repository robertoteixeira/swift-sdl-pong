# Swift SDL Pong

A small Pong clone built with **Swift** and **SDL3** on macOS.

The goal of this project is to explore a lightweight game loop, SDL rendering, keyboard input, collision detection, delta-time movement, and simple game architecture using Swift.

## Features

- SDL3 window and renderer setup
- Keyboard input using SDL scancodes
- Delta-time based movement
- Paddle and wall collision
- Paddle-based bounce angles
- Score system
- Custom 7-segment score rendering
- Multi-digit score support
- Game states:
  - Waiting to start
  - Playing
  - Paused
  - Game over
- Procedural SDL audio effects for wall hits, paddle hits, and scoring  

## Controls

| Key | Action |
|---|---|
| `W` | Move left paddle up |
| `S` | Move left paddle down |
| `↑` | Move right paddle up |
| `↓` | Move right paddle down |
| `Space` | Start game |
| `P` | Pause / resume |
| `R` | Restart after game over |
| `M` | Mute / unmute audio |
| `Esc` | Close the game |

## Requirements

- macOS
- Swift 6+
- Homebrew
- SDL3
- pkg-config

Install dependencies:

```bash
brew install sdl3 pkg-config
```

## Run

```bash
swift run
```

## Project Structure

```text
Sources/SwiftSDLPong/
  main.swift              SDL lifecycle and main game loop
  Game.swift              Game state, update logic, scoring, collisions
  GameConfiguration.swift Configurable game constants
  GameState.swift         Game state enum
  GameMode.swift          Single-player / two-player mode enum
  GameEvent.swift         Events emitted by game logic
  AudioPlayer.swift       Procedural SDL audio effects
  Renderer.swift          SDL rendering helpers
  Collision.swift         AABB collision helper
```

## Architecture Notes

`main.swift` owns the SDL lifecycle:

- Initializes SDL
- Creates the window and renderer
- Runs the main loop
- Forwards input to the game
- Calls update and render

`Game.swift` owns gameplay state:

- Paddles
- Ball
- Score
- Game state
- Movement
- Collision handling
- Scoring and restart logic

`Renderer.swift` owns drawing:

- Background
- Center line
- Score digits
- Paddles
- Ball

`GameEvent.swift` defines lightweight events emitted by the game logic:

- Wall hit
- Paddle hit
- Score

`AudioPlayer.swift` listens to those events from `main.swift` and plays procedural sine-wave sound effects using SDL audio streams.

## Why SDL?

SDL provides a small low-level layer for creating windows, handling input, rendering simple graphics, and playing audio. This project uses SDL directly from Swift through a system library target and a module map.

## Next Improvements

- Add SDL_ttf text rendering
- Add a start/pause/game-over overlay
- Add a gameplay GIF to this README