//
//  InactiveState.swift
//  Ompreng
//
//  Created by Evelin Alim Natadjaja on 13/05/26.
//

import SpriteKit
import GameplayKit

class InactiveState: GKState {
    
    unowned let player: PlayerEntity
    
    init(entity: PlayerEntity) {
        self.player = entity
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let node = player.component(ofType: GKSKNodeComponent.self)?.node else { return }
        
        // Stop all animation
        node.removeAllActions()
        
        // Transition
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let hide = SKAction.run { node.isHidden = true }
        node.run(SKAction.sequence([fadeOut, hide]))
        
        // Turn off physics
        node.physicsBody?.categoryBitMask = PhysicsCategory.none
        node.physicsBody?.velocity = .zero
        player.component(ofType: StateComponent.self)?.enterState(.inactive)
        
        print("Player \(player.side) is Inactive")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let posComponent = player.component(ofType: PositionComponent.self) else { return }
        
        // Update state every frame
        if posComponent.normalizedHandMidpoint != nil {
            stateMachine?.enter(ActiveState.self)
        }
    }
}
