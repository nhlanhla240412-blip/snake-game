# Snake Game - Delphi 13.1 FireMonkey

A classic Snake game built with Delphi 13.1 using the FireMonkey framework for Windows.

## Features

- Classic Snake gameplay mechanics
- Score tracking with high score persistence
- Pause/Resume functionality
- Keyboard controls (Arrow Keys or WASD)
- Grid-based rendering with visual feedback
- Game Over detection with collision prevention
- High score saved to Documents folder

## Project Structure

- **SnakeGame.dpr** - Main project file
- **SnakeGameUnit.pas** - Main form with UI and rendering
- **SnakeLogicUnit.pas** - Game logic and mechanics

## Controls

| Key | Action |
|-----|--------|
| Arrow Keys | Move Snake |
| W/A/S/D | Move Snake (Alternative) |
| ESC | Pause/Resume |
| Button | Start/Pause/Reset Game |

## Game Rules

1. The snake starts with 3 segments in the middle of the grid
2. Eat red food items to grow and gain points (10 points per food)
3. Avoid running into walls or yourself
4. Game ends when collision occurs
5. High score is automatically saved

## Building the Project

1. Open Delphi 13.1
2. Open **SnakeGame.dpr**
3. Set target to Windows platform
4. Press F9 to compile and run

### System Requirements

- Delphi 13.1 or later
- Windows 7 or later
- FireMonkey Framework

## Game Settings

You can customize the game by modifying:

- **CellSize**: Grid cell size (pixels) - in SnakeGameUnit.pas
- **GRID_WIDTH**: Game grid width - in SnakeLogicUnit.pas (default: 20)
- **GRID_HEIGHT**: Game grid height - in SnakeLogicUnit.pas (default: 20)
- **Timer Interval**: Speed of the game (milliseconds)

## High Score

The high score is saved to:
- Windows: `Documents\snake_highscore.txt`

The score is automatically loaded when the game starts and saved when a game ends with a new high score.

## Color Scheme

- **Green**: Snake head
- **Light Green**: Snake body
- **Red**: Food
- **White**: Game board
- **Light Gray**: Grid lines

## Future Enhancements

- Difficulty levels with increasing speed
- Sound effects
- Different game modes
- Multiplayer support
- Animation effects
- Theme customization

## License

Free to use and modify.

## Author

Created with Delphi 13.1 FireMonkey
