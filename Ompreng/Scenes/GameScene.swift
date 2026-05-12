import SpriteKit
import SwiftUI

class GameScene: SKScene {
    var spawner: DishSpawner?
    
    override func didMove(to view: SKView) {
        // Initialize game scene for iPad landscape
        self.size = CGSize(width: 1024, height: 768)
        self.backgroundColor = .white
        
        // Add physics world gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // Initialize dish spawner
        spawner = DishSpawner(scene: self, spawnInterval: 0.5)
        spawner?.start()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Remove dishes that have fallen off screen
        self.children.forEach { node in
            if let food = node as? FoodEntity, food.position.y < -50 {
                food.removeFromParent()
            }
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
