import SpriteKit
import SwiftUI
import GameplayKit

class GameScene: SKScene {

    var spawner: DishSpawner?
    var inGameState: InGameState?
    var tray: SKSpriteNode!

    private var gameMachine: GKStateMachine?
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        self.size = CGSize(width: 1024, height: 768)
        self.backgroundColor = .white
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self

        // Tray copied directly from pulled GameScene
        tray = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 30))
        tray.position = CGPoint(x: 512, y: 50)
        tray.zPosition = 100
        tray.physicsBody = SKPhysicsBody(rectangleOf: tray.size)
        tray.physicsBody?.isDynamic = false
        tray.physicsBody?.categoryBitMask = PhysicsCategory.player
        tray.physicsBody?.collisionBitMask = PhysicsCategory.none
        tray.physicsBody?.contactTestBitMask = PhysicsCategory.food
        self.addChild(tray)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.view?.addGestureRecognizer(panGesture)

        // InGameState handles timer, score, food bar, spawner
        let state = InGameState(scene: self)
        inGameState = state
        gameMachine = GKStateMachine(states: [state])
        gameMachine?.enter(InGameState.self)
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime
        gameMachine?.update(deltaTime: delta)

        children.forEach { node in
            if let food = node as? FoodEntity, food.position.y < -50 {
                food.removeFromParent()
            }
        }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = self.view else { return }
        let location = gesture.location(in: view)
        let sceneLocation = self.convertPoint(fromView: location)
        let trayHalfWidth = tray.size.width / 2
        tray.position.x = max(50 + trayHalfWidth, min(974 - trayHalfWidth, sceneLocation.x))
    }
}

// MARK: - Physics Contact

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        guard let food = (nodeA as? FoodEntity) ?? (nodeB as? FoodEntity) else { return }

        // Check contact with the raw tray node
        if nodeA === tray || nodeB === tray {
            inGameState?.HandleContactWithTray(food: food)
        }
    }
}

// MARK: - Preview

#Preview {
    let skView = SKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
    let scene = GameScene(size: CGSize(width: 1024, height: 768))
    scene.scaleMode = .resizeFill
    skView.presentScene(scene)
    skView.showsFPS = true
    skView.showsNodeCount = true
    return skView
}
