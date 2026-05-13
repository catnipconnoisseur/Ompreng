import GameplayKit
import CoreGraphics // Cukup CoreGraphics, jangan import SpriteKit di sini!

class PositionComponent: GKComponent {
    /**
     Data mentah dari kamera Vision.
     Rentang nilainya adalah 0.0 hingga 1.0 (Normalized).
     Jika nil, artinya tangan pemain sedang tidak terdeteksi oleh kamera.
     */
    var normalizedHandMidpoint: CGPoint?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
