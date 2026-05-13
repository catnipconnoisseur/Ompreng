import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    var spawner: DishSpawner?
<<<<<<< HEAD
=======
    var timerLabel: SKLabelNode!
    var remainingTime: TimeInterval = 120
    var tray: SKSpriteNode!
>>>>>>> ea5cfc6 (Add draggable tray and implement dish collision detection)
    
    override func didMove(to view: SKView) {
        // Initialize game scene for iPad landscape
        self.size = CGSize(width: 1024, height: 768)
        self.backgroundColor = .white
<<<<<<< HEAD
=======
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
>>>>>>> ea5cfc6 (Add draggable tray and implement dish collision detection)
        
        // Add physics world gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // Initialize dish spawner
        spawner = DishSpawner(scene: self, spawnInterval: 0.5)
        spawner?.start()
        
        // Setup Tray (Ompreng)
        tray = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 30))
        tray.position = CGPoint(x: 512, y: 50)
        tray.zPosition = 100
        tray.physicsBody = SKPhysicsBody(rectangleOf: tray.size)
        tray.physicsBody?.isDynamic = false
        tray.physicsBody?.categoryBitMask = PhysicsCategory.player
        tray.physicsBody?.collisionBitMask = PhysicsCategory.none
        self.addChild(tray)
        
        // Add pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.view?.addGestureRecognizer(panGesture)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Remove dishes that have fallen off screen
        self.children.forEach { node in
            if let food = node as? FoodEntity, food.position.y < -50 {
                food.removeFromParent()
            }
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = self.view else { return }
        let location = gesture.location(in: view)
        let sceneLocation = self.convertPoint(fromView: location)
        
        // Move tray to follow finger horizontally
        var newX = sceneLocation.x
        
        // Clamp tray to screen bounds (with 50px margins)
        let trayHalfWidth = tray.size.width / 2
        newX = max(50 + trayHalfWidth, min(974 - trayHalfWidth, newX))
        
        tray.position.x = newX
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Determine which body is food and which is player (tray)
        var foodBody: SKPhysicsBody?
        var playerBody: SKPhysicsBody?
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.food {
            foodBody = contact.bodyA
            playerBody = contact.bodyB
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.food {
            foodBody = contact.bodyB
            playerBody = contact.bodyA
        }
        
        // If collision is between food and player (tray), remove the dish
        if let food = foodBody?.node as? FoodEntity, playerBody?.categoryBitMask == PhysicsCategory.player {
            food.removeFromParent()
        }
    }
}

#Preview {
    GameScenePreviewContainer()
}

struct GameScenePreviewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        // iPad landscape dimensions
        let scene = GameScene(size: CGSize(width: 1024, height: 768))
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .white
        skView.presentScene(scene)
        skView.showsFPS = true
        skView.showsNodeCount = true
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
}
