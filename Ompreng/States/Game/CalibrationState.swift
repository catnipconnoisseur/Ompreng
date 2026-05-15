import GameplayKit
import SpriteKit

class CalibrationState: GKState {
    unowned let scene: GameScene
    var countdownTimer: TimeInterval = 3.0
    var isCalibrating: Bool = false
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        print("CALIBRATING")
        
        // Entity still on InactiveState when calibrating
        scene.playerLeft?.stateMachine?.enter(InactiveState.self)
        scene.playerRight?.stateMachine?.enter(InactiveState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let isPoseCorrect = checkPoseMetrics()
        
        if isPoseCorrect {
            isCalibrating = true
            countdownTimer -= seconds
            
            // Show at terminal
            let roundedTime = Double(round(10 * countdownTimer) / 10)
            print("Kalibrasi: \(roundedTime) detik...")
            
            if countdownTimer <= 0 {
                stateMachine?.enter(InGameState.self)
            }
        } else {
            if isCalibrating{ print("Calibration failed. Restarting...")}
            isCalibrating = false
            countdownTimer = 3.0
        }
    }
    
    private func checkPoseMetrics() -> Bool {
        guard let leftPos = scene.playerLeft?.component(ofType: PositionComponent.self),
              let rightPos = scene.playerRight?.component(ofType: PositionComponent.self) else { return false }
        
        return evaluateIndividualPose(for: leftPos, expectedSide: .left) && evaluateIndividualPose(for:rightPos, expectedSide: .right)
    }
    
    private func evaluateIndividualPose(for position: PositionComponent, expectedSide: PlayerSide) -> Bool {
        guard let lWrist = position.leftWrist, let rWrist = position.rightWrist, let root = position.rootPosition else { return false }
        
        // Separation Rules
        if expectedSide == .left && root.x > 0.5 { return false }
        if expectedSide == .right && root.x < 0.5 { return false }
        
        // Hand Height
        if lWrist.y > 0.5 || rWrist.y > 0.5 { return false }
        return true
        
        
    }
}
