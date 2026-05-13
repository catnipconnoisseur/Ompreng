import SpriteKit
import SwiftUI

class GameScene: SKScene {
    var spawner: DishSpawner?
    var timerLabel: SKLabelNode!
    var remainingTime: TimeInterval = 120
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: 1024, height: 768)
        self.backgroundColor = .white
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
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
