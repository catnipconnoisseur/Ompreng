import SpriteKit

public class DishFactory {
    /// Creates a new food entity with a random dish type
    static func createRandomDish(at position: CGPoint) -> FoodEntity {
        let randomFoodType = FoodType.random()
        return FoodEntity(foodType: randomFoodType, position: position)
    }
    
    /// Creates a food entity with a specific dish type
    static func createDish(of type: FoodType, at position: CGPoint) -> FoodEntity {
        return FoodEntity(foodType: type, position: position)
    }
}

public class DishSpawner {
    private var spawnTimer: Timer?
    private weak var scene: SKScene?
    private var spawnInterval: TimeInterval
    private let spawnWidth: CGFloat
    
    public init(scene: SKScene, spawnInterval: TimeInterval = 1.0) {
        self.scene = scene
        self.spawnInterval = spawnInterval
        self.spawnWidth = scene.size.width
    }
    
    /// Starts spawning random dishes at regular intervals
    public func start() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { [weak self] _ in
            self?.spawnRandomDish()
        }
    }
    
    /// Stops the spawning process
    public func stop() {
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    /// Spawns a single random dish at the top of the screen
    private func spawnRandomDish() {
        guard let scene = scene else { return }
        
        // Random horizontal position across the width of the screen
        let randomX = CGFloat.random(in: 20...(spawnWidth - 20))
        let spawnPosition = CGPoint(x: randomX, y: scene.size.height + 20)
        
        // Create a random dish using the factory
        let dish = DishFactory.createRandomDish(at: spawnPosition)
        scene.addChild(dish)
    }
    
    /// Sets the spawn interval (dishes per second)
    public func setSpawnInterval(_ interval: TimeInterval) {
        stop()
        let newInterval = max(0.1, interval) // Minimum 0.1 second interval
        self.spawnInterval = newInterval
        start()
    }
}

class PositionSystem {
    // Position system implementation
}
