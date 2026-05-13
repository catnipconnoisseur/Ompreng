import GameplayKit
import SpriteKit

class ActiveState : GKState {
    // Active state implementation
    unowned let player: PlayerEntity
    
    init(entity: PlayerEntity){
        self.player = entity
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let node = player.component(ofType: GKSKNodeComponent.self)?.node else { return }
        
        // 1. Munculkan ompreng
        node.isHidden = false
        node.alpha = 0
        node.removeAllActions()
        node.run(SKAction.fadeIn(withDuration: 0.1))
        
        // 2. Pastikan fisika menyala dan merespons dorongan
        node.physicsBody?.isDynamic = true
        node.physicsBody?.categoryBitMask = PhysicsCategory.player
        
        // Catat ke StateComponent (jika ada)
        player.component(ofType: StateComponent.self)?.enterState(.active)
        
        print("Player \(player.side) is Active")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let posComponent = player.component(ofType: PositionComponent.self),
              let renderComponent = player.component(ofType: GKSKNodeComponent.self),
              let scene = renderComponent.node.scene else { return }
        
        // Cek Input
        guard let rawNormalizedPos = posComponent.normalizedHandMidpoint else {
            // Jika tangan hilang/jari diangkat, pindah ke InactiveState
            stateMachine?.enter(InactiveState.self)
            return
        }
        
        // Batas Area
        let sceneWidth = scene.size.width
        let sceneHeight = scene.size.height
        
        // Batas Bawah: 1/4 tinggi layar (0.0 - 0.25)
        let targetY = rawNormalizedPos.y * (sceneHeight * 0.25)
        
        // Batas Jelajah: 75% (0.75) dan 25% (0.25)
        let maxOverlapLeft = sceneWidth * 0.75
        let minOverlapRight = sceneWidth * 0.25
        let rightAreaWidth = sceneWidth - minOverlapRight // Sama dengan 75% layar
        
        var targetX: CGFloat = 0
        
        switch player.side {
        case .left:
            // Petakan input X Vision penuh (0.0 - 1.0) ke rentang 0 hingga 75% layar
            targetX = rawNormalizedPos.x * maxOverlapLeft
            
        case .right:
            // Petakan input X Vision penuh (0.0 - 1.0) ke rentang 25% hingga 100% layar
            targetX = minOverlapRight + (rawNormalizedPos.x * rightAreaWidth)
        }
        
        // Physics collision ompreng
        let node = renderComponent.node
        let currentPos = node.position
        
        let dx = targetX - currentPos.x
        let dy = targetY - currentPos.y
        
        // Spring Constant
        let springConstant: CGFloat = 10.0
        
        if let physicsBody = node.physicsBody {
            // Terapkan kecepatan ke arah target
            physicsBody.velocity = CGVector(dx: dx * springConstant, dy: dy * springConstant)
        }
    }
    
    override func willExit(to nextState: GKState) {
        // Hentikan pergerakan saat keluar dari state ini (misal kena Frozen)
        player.component(ofType: GKSKNodeComponent.self)?.node.physicsBody?.velocity = .zero
    }
}
