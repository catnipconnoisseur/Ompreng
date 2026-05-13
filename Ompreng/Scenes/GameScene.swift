import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    var spawner: DishSpawner?
    var timerLabel: SKLabelNode!
    var remainingTime: TimeInterval = 120
    var tray: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: 1024, height: 768)
        self.backgroundColor = .white
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
        
        // Setup Timer
        timerLabel = SKLabelNode(fontNamed: "Arial")
        timerLabel.fontSize = 64
        timerLabel.fontColor = .black
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.verticalAlignmentMode = .center
        timerLabel.position = CGPoint(x: 570, y: 680)
        timerLabel.zPosition = 1000
        timerLabel.text = "2:00"
        self.addChild(timerLabel)
        
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
        remainingTime -= 1/60.0
        
        if remainingTime < 0 {
            remainingTime = 0
        }
        
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        timerLabel.text = String(format: "%d:%02d", minutes, seconds)
        
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
    let skView = SKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
    let scene = GameScene(size: CGSize(width: 1024, height: 768))
    scene.scaleMode = .resizeFill
    skView.presentScene(scene)
    skView.showsFPS = true
    skView.showsNodeCount = true
    return skView
}
