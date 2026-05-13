import GameplayKit
import SpriteKit

class FrozenState: GKState {
    
    unowned let player: PlayerEntity
    let freezeDuration: TimeInterval = 1.0
    
    init(entity: PlayerEntity) {
        self.player = entity
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let node = player.component(ofType: GKSKNodeComponent.self)?.node else { return }
        
        // Stop animation
        node.removeAllActions()
        
        // Visual feedback
        let turnBlue = SKAction.colorize(with: .cyan, colorBlendFactor: 0.8, duration: 0.1)
        let vibrate = SKAction.sequence([
            SKAction.moveBy(x: 3, y: 0, duration: 0.05),
            SKAction.moveBy(x: -6, y: 0, duration: 0.05),
            SKAction.moveBy(x: 3, y: 0, duration: 0.05)
        ])
        node.run(SKAction.group([turnBlue, SKAction.repeatForever(vibrate)]))
        
        // Stop physics
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
        guard let node = player.component(ofType: GKSKNodeComponent.self)?.node else { return }
        
        node.removeAllActions()
        node.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1))
        node.physicsBody?.contactTestBitMask = PhysicsCategory.food | PhysicsCategory.player
    }
}
