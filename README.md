# Ompreng

A SpriteKit-based iOS game featuring entity-component-system (ECS) architecture.

## Project Structure

- **Scenes**: Game scenes (MainMenu, Tutorial, Game, GameOver)
- **Entities**: Core game entities (Player, Food)
- **Components**: Reusable components for ECS architecture
  - PositionComponent
  - ScoreComponent
  - FoodBarComponent
  - FoodTypeComponent
  - StateComponent
- **Systems**: Game systems for processing entities
  - PositionSystem
  - StateSystem
  - CollisionSystem
- **States**: Game and player state management
  - Game states: MainMenu, Calibration, InGame, GameOver
  - Player states: Active, Frozen

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.3+

## Build & Run

1. Open `Ompreng.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

## License

MIT
