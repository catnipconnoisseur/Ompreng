import GameplayKit
import SpriteKit

class FrozenState: GKState {
    
    unowned let player: PlayerEntity
    let freezeDuration: TimeInterval = 2.0
    
    init(entity: PlayerEntity) {
        self.player = entity
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let node = player.component(ofType: GKSKNodeComponent.self)?.node as? SKSpriteNode else { return }
        
        // Stop animation
        node.removeAllActions()
        
        // Texture
        node.texture = SKTexture(imageNamed: "OmprengFreeze")
        
        
        // Visual feedback
        let vibrate = SKAction.sequence([
            SKAction.moveBy(x: 3, y: 0, duration: 0.05),
            SKAction.moveBy(x: -6, y: 0, duration: 0.05),
            SKAction.moveBy(x: 3, y: 0, duration: 0.05)
        ])
        
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        
        let penaltyLoop = SKAction.group([
            SKAction.repeatForever(vibrate),
            SKAction.repeatForever(blink)
        ])
        
        node.run(penaltyLoop, withKey: "frozenVisuals")
        
        // Stop physics
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.velocity = .zero
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player
        player.component(ofType: StateComponent.self)?.enterState(.frozen)
        print("Player \(player.side) is FROZEN!")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateComp = player.component(ofType: StateComponent.self) else { return }
        
        // Tambahkan waktu ke timer
        stateComp.stateTimer += seconds
        
        // Cek apakah hukuman sudah selesai
        if stateComp.stateTimer >= freezeDuration {
            // Evaluasi kemana harus kembali setelah cair
            if player.component(ofType: PositionComponent.self)?.normalizedHandMidpoint != nil {
                stateMachine?.enter(ActiveState.self)
            } else {
                stateMachine?.enter(InactiveState.self)
            }
        }
    }
    
    override func willExit(to nextState: GKState) {
        guard let node = player.component(ofType: GKSKNodeComponent.self)?.node as? SKSpriteNode else { return }
        
        node.removeAction(forKey: "frozenVisuals")
        node.removeAllActions()
        
        node.alpha = 1.0
        
        node.texture = SKTexture(imageNamed: "OmprengNormal")
        
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.contactTestBitMask = PhysicsCategory.food | PhysicsCategory.player
    }
}
