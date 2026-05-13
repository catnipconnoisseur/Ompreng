import SpriteKit
import GameplayKit

public enum PlayerSide {
    case left
    case right
}

class PlayerEntity : GKEntity {
    // Player entity implementation
    let side: PlayerSide
    var stateMachine: GKStateMachine?
    
    //Inisialisasi PlayerEntity
    
    init(node: SKSpriteNode, side: PlayerSide){
        self.side = side
        super.init()
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = true // Harus true agar bisa terdorong
        
        // Tuning dinamika fisika
        node.physicsBody?.mass = 5.0 // Cukup berat agar dorongan terasa "solid"
        node.physicsBody?.restitution = 0.2 // Sedikit memantul saat tabrakan antar pemain
        node.physicsBody?.linearDamping = 0.8 // Hambatan geser agar ompreng tidak licin seperti di atas es
        node.physicsBody?.allowsRotation = false // Cegah ompreng terbalik secara visual
        
        // Setup Bitmask sesuai PhysicsCategory milikmu
        node.physicsBody?.categoryBitMask = PhysicsCategory.player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.food | PhysicsCategory.player
        node.physicsBody?.collisionBitMask = PhysicsCategory.player // Mengizinkan tabrakan fisik dengan player lain
        
        // Agar Scene bisa mengenali entitas ini saat tabrakan
        node.entity = self
        
        //Component ECS
        addComponent(GKSKNodeComponent(node:node))
        addComponent(PositionComponent())
        addComponent(FoodBarComponent())
        addComponent(ScoreComponent())
        addComponent(StateComponent())
        
        //State Machine
        stateMachine = GKStateMachine(states: [
            InactiveState(entity: self),
             ActiveState(entity: self),
            FrozenState(entity: self)
        ])
        
        stateMachine?.enter(InactiveState.self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Fungsi ini wajib ada agar State Machine berjalan setiap frame
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        stateMachine?.update(deltaTime: seconds)
    }
    
}
