import GameplayKit
import SpriteKit

// MARK: - Constants

private enum GameConfig {
    static let gameDuration: TimeInterval = 120
    static let frozenDuration: TimeInterval = 1
    static let completedMealBonus: Int = 1
    static let heightLimitFraction: CGFloat = 1.0 / 3.0
    static let initialSpawnInterval: TimeInterval = 0.5
    static let speedUpInterval: TimeInterval = 15.0
    static let spawnDecreaseRate:TimeInterval = 0.05
}

// MARK: - InGameState

class InGameState: GKState {
    
    // MARK: Properties
    
    private weak var scene: GameScene?
    
    // Player one is represented by the raw tray in GameScene for now.
    // PlayerEntity is kept for score, food bar, and state tracking only — not for its node.
    private weak var playerOne: PlayerEntity?
    private weak var playerTwo: PlayerEntity?
    
    private var timeRemaining: TimeInterval = GameConfig.gameDuration
    private var isGameOver = false
    private var currentSpawnInterval: TimeInterval = GameConfig.initialSpawnInterval
    private var nextSpeedUpTime: TimeInterval = 0
    
    private var timerLabel: SKLabelNode?
    private var playerOneScoreLabel: SKLabelNode?
    private var playerTwoScoreLabel: SKLabelNode?
    
    private var playerOneFoodBarNodes: [FoodType: SKShapeNode] = [:]
    private var playerTwoFoodBarNodes: [FoodType: SKShapeNode] = [:]
    
    // MARK: Init
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    // MARK: GKState Lifecycle
    
    override func didEnter(from previousState: GKState?) {
        guard let scene else { return }
        
        timeRemaining = GameConfig.gameDuration
        isGameOver = false
        
        // Logic for speeding up
        currentSpawnInterval = GameConfig.initialSpawnInterval
        nextSpeedUpTime = GameConfig.gameDuration - GameConfig.speedUpInterval
        
        self.playerOne = scene.playerLeft
        self.playerTwo = scene.playerRight
        
        playerOne?.stateMachine?.enter(ActiveState.self)
        playerTwo?.stateMachine?.enter(ActiveState.self)
        
        //SetupPlayers()
        SetupUI(in: scene)
        
        scene.spawner = DishSpawner(scene: scene, spawnInterval: currentSpawnInterval)
        scene.spawner?.start()
    }
    
    override func willExit(to nextState: GKState) {
        scene?.spawner?.stop()
        TeardownUI()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    
    // MARK: Update
    
    override func update(deltaTime seconds: TimeInterval) {
        guard !isGameOver else { return }
        guard let scene else { return }
        
        timeRemaining -= seconds
        UpdateTimerLabel()
        
        if timeRemaining <= 0 {
            timeRemaining = 0
            isGameOver = true
            scene.spawner?.stop()
            ShowEndGameOverlay()
            return
        }
        
        // Speeding up as time progresses
        if timeRemaining <= nextSpeedUpTime && timeRemaining > 0 {
            nextSpeedUpTime -= GameConfig.speedUpInterval
            
            currentSpawnInterval -= GameConfig.spawnDecreaseRate
            currentSpawnInterval = max(0.1, currentSpawnInterval)
            
            scene.spawner?.setSpawnInterval(currentSpawnInterval)
            print("Speed Up!")
        }
        
        // Tick state machines
        playerOne?.update(deltaTime: seconds)
        playerTwo?.update(deltaTime: seconds)
    }
    
    // MARK: - Setup
    
    //    private func SetupPlayers() {
    //        // PlayerEntity is used for game logic only (score, food bar, state machine).
    //        // The visible tray node lives directly on GameScene — no GKSKNodeComponent needed.
    //        let dummyNodeOne = SKSpriteNode()
    //        playerOne = PlayerEntity(node: dummyNodeOne, side: .left)
    //
    //        let dummyNodeTwo = SKSpriteNode()
    //        playerTwo = PlayerEntity(node: dummyNodeTwo, side: .right)
    //
    //        playerOne?.stateMachine?.enter(ActiveState.self)
    //        playerTwo?.stateMachine?.enter(ActiveState.self)
    //    }
    
    private func SetupUI(in scene: GameScene) {
        let sceneWidth = scene.size.width
        let sceneHeight = scene.size.height
        
        let timer = SKLabelNode(fontNamed: "Helvetica-Bold")
        timer.fontSize = 36
        timer.fontColor = .black
        timer.verticalAlignmentMode = .top
        timer.position = CGPoint(x: sceneWidth / 2, y: sceneHeight - 10)
        timer.zPosition = 10
        timer.name = "timerLabel"
        scene.addChild(timer)
        timerLabel = timer
        
        let p1Score = SKLabelNode(fontNamed: "Helvetica-Bold")
        p1Score.fontSize = 28
        p1Score.fontColor = .black
        p1Score.horizontalAlignmentMode = .left
        p1Score.verticalAlignmentMode = .top
        p1Score.position = CGPoint(x: 20, y: sceneHeight - 10)
        p1Score.zPosition = 10
        p1Score.name = "p1ScoreLabel"
        scene.addChild(p1Score)
        playerOneScoreLabel = p1Score
        
        let p2Score = SKLabelNode(fontNamed: "Helvetica-Bold")
        p2Score.fontSize = 28
        p2Score.fontColor = .black
        p2Score.horizontalAlignmentMode = .right
        p2Score.verticalAlignmentMode = .top
        p2Score.position = CGPoint(x: sceneWidth - 20, y: sceneHeight - 10)
        p2Score.zPosition = 10
        p2Score.name = "p2ScoreLabel"
        scene.addChild(p2Score)
        playerTwoScoreLabel = p2Score
        
        playerOneFoodBarNodes = BuildFoodBar(side: .left, in: scene)
        playerTwoFoodBarNodes = BuildFoodBar(side: .right, in: scene)
        
        UpdateTimerLabel()
        UpdateScoreLabel(for: playerOne, label: playerOneScoreLabel)
        UpdateScoreLabel(for: playerTwo, label: playerTwoScoreLabel)
        UpdateFoodBarUI(for: playerOne, nodes: playerOneFoodBarNodes)
        UpdateFoodBarUI(for: playerTwo, nodes: playerTwoFoodBarNodes)
    }
    
    // MARK: - Food Bar
    
    private func BuildFoodBar(side: PlayerSide, in scene: GameScene) -> [FoodType: SKShapeNode] {
        let sceneWidth = scene.size.width
        let circleRadius: CGFloat = 18
        let spacing: CGFloat = 46
        let y: CGFloat = 30
        let totalWidth = spacing * CGFloat(FoodType.allCases.count - 1)
        let startX: CGFloat = side == .left ? 30 : sceneWidth - 30 - totalWidth
        
        var nodes: [FoodType: SKShapeNode] = [:]
        for (index, foodType) in FoodType.allCases.enumerated() {
            let circle = SKShapeNode(circleOfRadius: circleRadius)
            circle.fillColor = .gray
            circle.strokeColor = .darkGray
            circle.lineWidth = 1
            circle.position = CGPoint(x: startX + CGFloat(index) * spacing, y: y)
            circle.zPosition = 10
            circle.name = "\(side)_foodbar_\(foodType.displayName)"
            scene.addChild(circle)
            nodes[foodType] = circle
        }
        return nodes
    }
    
    // MARK: - Contact Handling
    
    /// Called by GameScene when food hits the raw tray node (player one).
    func HandleContactWithTray(food: FoodEntity, for player: PlayerEntity) {
        guard !isGameOver else { return }
        
        guard let stateComponent = player.component(ofType: StateComponent.self),
              stateComponent.currentState != .frozen else { return }
        
        guard let foodBar = player.component(ofType: FoodBarComponent.self) else { return }
        
        if foodBar.canAddFood(food.foodType) {
            foodBar.addFood(food.foodType)
            food.removeFromParent()
            if foodBar.isComplete() {
                CompleteMeal(for: player)
            }
        } else {
            ApplyDuplicatePenalty(to: player)
            food.removeFromParent()
        }
        
        // Updating UI for two players mechanics
        if player.side == .left {
            UpdateScoreLabel(for: player, label: playerOneScoreLabel)
            UpdateFoodBarUI(for: player, nodes: playerOneFoodBarNodes)
        } else {
            UpdateScoreLabel(for: player, label: playerTwoScoreLabel)
            UpdateFoodBarUI(for: player, nodes: playerTwoFoodBarNodes)
        }
        
    }
    
    // MARK: - Game Logic
    
    private func CompleteMeal(for player: PlayerEntity) {
        guard let scoreComponent = player.component(ofType: ScoreComponent.self),
              let foodBar = player.component(ofType: FoodBarComponent.self) else { return }
        scoreComponent.currentScore += GameConfig.completedMealBonus
        foodBar.reset()
    }
    
    private func ApplyDuplicatePenalty(to player: PlayerEntity) {
        guard let scoreComponent = player.component(ofType: ScoreComponent.self),
              let stateComponent = player.component(ofType: StateComponent.self) else { return }
        
        stateComponent.enterState(.frozen)
        player.stateMachine?.enter(FrozenState.self)
        
        let wait = SKAction.wait(forDuration: GameConfig.frozenDuration)
        let unfreeze = SKAction.run { [weak player, weak stateComponent] in
            stateComponent?.enterState(.active)
            player?.stateMachine?.enter(ActiveState.self)
        }
        scene?.run(SKAction.sequence([wait, unfreeze]))
    }
    
    // MARK: - End Game
    
    private func ShowEndGameOverlay() {
        guard let scene else { return }
        
        let p1Score = playerOne?.component(ofType: ScoreComponent.self)?.currentScore ?? 0
        let p2Score = playerTwo?.component(ofType: ScoreComponent.self)?.currentScore ?? 0
        
        let p1Text: String
        let p2Text: String
        
        if p1Score > p2Score {
            p1Text = "MENANG!"; p2Text = "KALAH..."
        } else if p2Score > p1Score {
            p1Text = "KALAH..."; p2Text = "MENANG!"
        } else {
            p1Text = "SERI"; p2Text = "SERI"
        }
        
        PlaceEndLabel(text: p1Text, x: scene.size.width * 0.25, in: scene)
        PlaceEndLabel(text: p2Text, x: scene.size.width * 0.75, in: scene)
    }
    
    private func PlaceEndLabel(text: String, x: CGFloat, in scene: GameScene) {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 64
        label.verticalAlignmentMode = .center
        label.fontColor = text == "Winner" ? .systemGreen : (text == "Loser" ? .systemRed : .gray)
        label.position = CGPoint(x: x, y: scene.size.height / 2)
        label.zPosition = 20
        label.name = "endLabel"
        scene.addChild(label)
    }
    
    // MARK: - UI Updates
    
    private func UpdateTimerLabel() {
        timerLabel?.text = "\(max(0, Int(timeRemaining)))"
    }
    
    private func UpdateScoreLabel(for player: PlayerEntity?, label: SKLabelNode?) {
        let score = player?.component(ofType: ScoreComponent.self)?.currentScore ?? 0
        label?.text = "Score: \(score)"
    }
    
    private func UpdateFoodBarUI(for player: PlayerEntity?, nodes: [FoodType: SKShapeNode]) {
        guard let foodBar = player?.component(ofType: FoodBarComponent.self) else { return }
        for foodType in FoodType.allCases {
            nodes[foodType]?.fillColor = foodBar.collectedFoods.contains(foodType)
            ? foodType.color
            : .gray
        }
    }
    
    // MARK: - Helpers
    
    private func TeardownUI() {
        let managedNames: Set<String> = ["timerLabel", "p1ScoreLabel", "p2ScoreLabel", "endLabel"]
        scene?.children
            .filter { managedNames.contains($0.name ?? "") || ($0.name?.contains("_foodbar_") == true) }
            .forEach { $0.removeFromParent() }
    }
}
