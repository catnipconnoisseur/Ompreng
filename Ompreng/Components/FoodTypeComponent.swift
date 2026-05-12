import GameplayKit

class FoodTypeComponent: GKComponent {
    // Food type component implementation
    let type: FoodType
    
    init(type: FoodType) {
        self.type = type
        super.init()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
