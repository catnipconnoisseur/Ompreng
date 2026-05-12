import GameplayKit

class ScoreComponent: GKComponent {
    // Score component implementation
    var currentScore: Int
    
    init(initialScore: Int = 0) {
        self.currentScore = initialScore
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
