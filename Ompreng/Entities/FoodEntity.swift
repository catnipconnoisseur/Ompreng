import SpriteKit

public class FoodEntity: SKSpriteNode {
    let foodTypeComponent: FoodTypeComponent
    
    var dishType: DishType {
        return foodTypeComponent.dishType
    }
    
    init(dishType: DishType, position: CGPoint) {
        self.foodTypeComponent = FoodTypeComponent(dishType: dishType)
        super.init(texture: nil, color: dishType.color, size: CGSize(width: 40, height: 40))
        
        self.position = position
        self.name = "food_\(dishType.rawValue)"
        self.zPosition = 1
        
        // Add physics for collision detection
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.food
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 1
    static let food: UInt32 = 0x1 << 2
}
