import GameplayKit

class StateComponent: GKComponent {
    // State component implementation
    enum PlayerState {
        case inactive
        case active
        case frozen
    }
    
    var currentState: PlayerState = .inactive
    
    // Track duration of frozen
    var stateTimer: TimeInterval = 0
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enterState(_ state: PlayerState) {
        self.currentState = state
        self.stateTimer = 0
    }
}
