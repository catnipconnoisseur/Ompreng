import SpriteKit

enum FoodType: CaseIterable {
    case nasi
    case ayam
    case semangka
    case brokoli
    case susu
    
    var displayName: String {
        switch self {
        case .nasi:      return "Nasi"
        case .ayam:      return "Ayam"
        case .semangka:  return "Semangka"
        case .brokoli:   return "Brokoli"
        case .susu:      return "Susu"
        }
    }
    
    // Implementing asset for each food type with texture
    
    var textureName: String{
        switch self {
        case .nasi:      return "Nasi"
        case .ayam:      return "Ayam"
        case .semangka:  return "Semangka"
        case .brokoli:   return "Brokoli"
        case .susu:      return "Susu"
        }
    }
    
    var barCollectedTextureName: String {
        switch self {
        case .nasi:      return "ActiveBarNasi"
        case .ayam:      return "ActiveBarAyam"
        case .semangka:  return "ActiveBarSemangka"
        case .brokoli:   return "ActiveBarBrokoli"
        case .susu:      return "ActiveBarSusu"
        }
    }
    
    var barUncollectedTextureName: String {
        switch self {
        case .nasi:      return "InactiveBarNasi"
        case .ayam:      return "InactiveBarAyam"
        case .semangka:  return "InactiveBarSemangka"
        case .brokoli:   return "InactiveBarBrokoli"
        case .susu:      return "InactiveBarSusu"
        }
    }
    
    // Colors for Food Bar
    //    var color: SKColor {
    //        switch self {
    //        case .nasi:      return SKColor(red: 0.96, green: 0.87, blue: 0.60, alpha: 1)
    //        case .ayam:      return SKColor(red: 0.93, green: 0.58, blue: 0.19, alpha: 1)
    //        case .semangka:  return SKColor(red: 0.93, green: 0.25, blue: 0.30, alpha: 1)
    //        case .brokoli:   return SKColor(red: 0.27, green: 0.73, blue: 0.35, alpha: 1)
    //        case .susu:      return SKColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
    //        }
    //    }
    
    static func random() -> FoodType {
        return allCases.randomElement() ?? .nasi
    }
}

public class FoodEntity: SKSpriteNode {
    let foodTypeComponent: FoodTypeComponent
    
    var foodType: FoodType {
        return foodTypeComponent.type
    }
    
    init(foodType: FoodType, position: CGPoint) {
        self.foodTypeComponent = FoodTypeComponent(type: foodType)
        
        // Declare texture
        let texture = SKTexture(imageNamed: foodType.textureName)
        
        let foodSize = CGSize(width: 70, height: 70)
        super.init(texture: texture, color: .clear, size: foodSize)
        
        self.position = position
        self.name = "food_\(foodType.displayName)"
        self.zPosition = 1
        
        // Optimizing hitbox size
        let hitboxSize = CGSize(width: foodSize.width * 0.7, height: foodSize.height * 0.7)
        self.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
        
        // Add physics for collision detection
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
