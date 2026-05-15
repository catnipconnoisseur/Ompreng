import SpriteKit
import SwiftUI
import GameplayKit

class GameScene: SKScene {
    
    var spawner: DishSpawner?
    var inGameState: InGameState?
    //var tray: SKSpriteNode!
    
    // Using real player entity
    var playerLeft: PlayerEntity!
    var playerRight: PlayerEntity!
    
    private var gameMachine: GKStateMachine?
    private var lastUpdateTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: 1024, height: 768)
        self.backgroundColor = .white
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
        
        // For Touch Input
        view.isMultipleTouchEnabled = true
        
        // PlayerEntity setup
        let nodeLeft = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 30))
        nodeLeft.position = CGPoint(x: 256, y: 100)
        self.addChild(nodeLeft)
        playerLeft = PlayerEntity(node: nodeLeft, side: .left)
        
        let nodeRight = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 30))
        nodeRight.position = CGPoint(x: 768, y: 100)
        self.addChild(nodeRight)
        playerRight = PlayerEntity(node: nodeRight, side: .right)
        
        
        // Tray copied directly from pulled GameScene
        //        tray = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 30))
        //        tray.position = CGPoint(x: 512, y: 50)
        //        tray.zPosition = 100
        //        tray.physicsBody = SKPhysicsBody(rectangleOf: tray.size)
        //        tray.physicsBody?.isDynamic = false
        //        tray.physicsBody?.categoryBitMask = PhysicsCategory.player
        //        tray.physicsBody?.collisionBitMask = PhysicsCategory.none
        //        tray.physicsBody?.contactTestBitMask = PhysicsCategory.food
        //        self.addChild(tray)
        //
        //        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        //        self.view?.addGestureRecognizer(panGesture)
        
        // InGameState handles timer, score, food bar, spawner
        let state = InGameState(scene: self)
        self.inGameState = state
        gameMachine = GKStateMachine(states: [
            CalibrationState(scene: self),
            state
        ])
        gameMachine?.enter(CalibrationState.self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime
        gameMachine?.update(deltaTime: delta)
        playerLeft.update(deltaTime: delta)
        playerRight.update(deltaTime: delta)
        
        children.forEach { node in
            if let food = node as? FoodEntity, food.position.y < -50 {
                food.removeFromParent()
            }
        }
    }
    
    // MARK: - Touch Injection Multi-Touch
    
    private func injectCalibrationMockData(_ touches: Set<UITouch>, isEnding: Bool = false){
        let posLeft = playerLeft.component(ofType: PositionComponent.self)
        let posRight = playerRight.component(ofType: PositionComponent.self)
        
        for touch in touches{
            let location = touch.location(in: self)
            let normalizedX = location.x / size.width
            let normalizedY = location.y / size.height
            let isLeftSide = normalizedX < 0.5
            
            if isEnding{
                if isLeftSide{
                    posLeft?.normalizedHandMidpoint = nil
                    posLeft?.leftWrist = nil
                    posRight?.rightWrist = nil
                    posLeft?.rootPosition = nil
                }
                else {
                    posRight?.normalizedHandMidpoint = nil
                    posRight?.leftWrist = nil
                    posRight?.rightWrist = nil
                    posRight?.rootPosition = nil
                }
                continue
            }
            
            // Dummy data
            if isLeftSide {
                posLeft?.normalizedHandMidpoint = CGPoint(x: normalizedX, y: normalizedY)
                posLeft?.rootPosition = CGPoint(x: 0.25, y: 0.2)
                posLeft?.leftWrist = CGPoint(x: 0.15, y: normalizedY)
                posLeft?.rightWrist = CGPoint(x: 0.35, y: normalizedY)
            } else {
                posRight?.normalizedHandMidpoint = CGPoint(x: normalizedX, y: normalizedY)
                posRight?.rootPosition = CGPoint(x: 0.75, y: 0.2)
                posRight?.leftWrist = CGPoint(x: 0.65, y: normalizedY)
                posRight?.rightWrist = CGPoint(x: 0.85, y: normalizedY)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        injectCalibrationMockData(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        injectCalibrationMockData(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        injectCalibrationMockData(touches, isEnding: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        injectCalibrationMockData(touches, isEnding: true)
    }
    
    //
    //    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
    //        guard let view = self.view else { return }
    //        let location = gesture.location(in: view)
    //        let sceneLocation = self.convertPoint(fromView: location)
    //        let trayHalfWidth = tray.size.width / 2
    //        tray.position.x = max(50 + trayHalfWidth, min(974 - trayHalfWidth, sceneLocation.x))
    //    }
}

// MARK: - Physics Contact

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        guard let food = (nodeA as? FoodEntity) ?? (nodeB as? FoodEntity) else { return }
        
        // Contact detection with PlayerEntity
        let leftNode = playerLeft.component(ofType: GKSKNodeComponent.self)?.node
        let rightNode = playerRight.component(ofType: GKSKNodeComponent.self)?.node
        
        if nodeA === leftNode || nodeB === leftNode {
            inGameState?.HandleContactWithTray(food: food, for: playerLeft)
        }
        else if nodeA === rightNode || nodeB === rightNode {
            inGameState?.HandleContactWithTray(food: food, for: playerRight
            )
        }
        
//        // Check contact with the raw tray node
//        if nodeA === tray || nodeB === tray {
//            inGameState?.HandleContactWithTray(food: food)
//        }
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
