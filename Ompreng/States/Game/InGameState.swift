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
    private weak var playerOne: PlayerEntity?
    private weak var playerTwo: PlayerEntity?
    
    private var timeRemaining: TimeInterval = GameConfig.gameDuration
    private var isGameOver = false
    private var currentSpawnInterval: TimeInterval = GameConfig.initialSpawnInterval
    private var nextSpeedUpTime: TimeInterval = 0

    private var timerLabel: SKLabelNode?
    private var playerOneScoreLabel: SKLabelNode?
    private var playerTwoScoreLabel: SKLabelNode?

    private var playerOneScoreBox: SKSpriteNode?
    private var playerTwoScoreBox: SKSpriteNode?

    private var playerOneFoodBarNodes: [FoodType: SKSpriteNode] = [:]
    private var playerTwoFoodBarNodes: [FoodType: SKSpriteNode] = [:]
    
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
    
    // MARK: - Setup UI
    
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
        let topY = sceneHeight - 60
        
        // Color
        let timerUI = CreateUICard(
                title: "WAKTU",
                value: "120",
                imageName: "BarTime", // Nama file PNG kamu
                textColor: .black,
                iconName: nil,
                isIconLeft: false
            )
            timerUI.bgNode.position = CGPoint(x: sceneWidth / 2, y: topY)
            timerUI.bgNode.zPosition = 50
            scene.addChild(timerUI.bgNode)
            self.timerLabel = timerUI.labelNode
        
        // UI Score Left Player
        let p1UI = CreateUICard(
                title: "PEMAIN 1",
                value: "0",
                imageName: "BarScore",
                textColor: .white,
                iconName: "OmprengWithDishLeft",
                isIconLeft: true
            )
            p1UI.bgNode.position = CGPoint(x: 180, y: topY)
            p1UI.bgNode.zPosition = 50
            scene.addChild(p1UI.bgNode)
            self.playerOneScoreLabel = p1UI.labelNode
            self.playerOneScoreBox = p1UI.bgNode
        
        // UI Score Right Player
        let p2UI = CreateUICard(
                title: "PEMAIN 2",
                value: "0",
                imageName: "BarScore",
                textColor: .white,
                iconName: "OmprengWithDishRight",
                isIconLeft: false
            )
            p2UI.bgNode.position = CGPoint(x: sceneWidth - 180, y: topY)
            p2UI.bgNode.zPosition = 100
            scene.addChild(p2UI.bgNode)
            self.playerTwoScoreLabel = p2UI.labelNode
            self.playerTwoScoreBox = p2UI.bgNode
        
        playerOneFoodBarNodes = BuildFoodBar(side: .left, in: scene)
        playerTwoFoodBarNodes = BuildFoodBar(side: .right, in: scene)
        
        UpdateTimerLabel()
        UpdateScoreLabel(for: playerOne, label: playerOneScoreLabel)
        UpdateScoreLabel(for: playerTwo, label: playerTwoScoreLabel)
        UpdateFoodBarUI(for: playerOne, nodes: playerOneFoodBarNodes)
        UpdateFoodBarUI(for: playerTwo, nodes: playerTwoFoodBarNodes)
    }
    
    // MARK: - Food Bar
    
    private func BuildFoodBar(side: PlayerSide, in scene: GameScene) -> [FoodType: SKSpriteNode] {
        let sceneWidth = scene.size.width
        
        let iconSize = CGSize(width: 80, height: 80)
        let spacing: CGFloat = 46
        let y: CGFloat = 50
        let totalWidth = spacing * CGFloat(FoodType.allCases.count - 1)
        let startX: CGFloat = side == .left ? 50 : sceneWidth - 50 - totalWidth
        
        var nodes: [FoodType: SKSpriteNode] = [:]
        for (index, foodType) in FoodType.allCases.enumerated() {
            let texture = SKTexture(imageNamed: foodType.barUncollectedTextureName)
            let icon = SKSpriteNode(texture: texture, size:iconSize)
            
            icon.position = CGPoint(x: startX + CGFloat(index) * spacing, y: y)
            icon.zPosition = 10
            icon.name = "\(side)_foodbar_\(foodType.displayName)"
            scene.addChild(icon)
            nodes[foodType] = icon
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
        
        // Zoom effect
        AnimateScoreZoom(for: player)
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
        label.fontColor = text == "Winner" ? .black : (text == "Loser" ? .systemRed : .black)
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
        label?.text = "\(score)"
    }
    
    private func UpdateFoodBarUI(for player: PlayerEntity?, nodes: [FoodType: SKSpriteNode]) {
        guard let foodBar = player?.component(ofType: FoodBarComponent.self) else { return }
        for foodType in FoodType.allCases {
            if foodBar.collectedFoods.contains(foodType) {
                nodes[foodType]?.texture = SKTexture(imageNamed: foodType.barCollectedTextureName)
            } else {
                nodes[foodType]?.texture = SKTexture(imageNamed: foodType.barUncollectedTextureName)
            }
        }
    }
    
    // MARK: - Visual Feedback
    
    private func AnimateScoreZoom(for player: PlayerEntity){
        let targetBox = player.side == .left ? playerOneScoreBox : playerTwoScoreBox
        
        // Normal condition
        targetBox?.removeAllActions()
        targetBox?.setScale(1.0)
        
        // Zoom in effect
        let zoomIn = SKAction.scale(to: 1.3, duration: 0.1)
        zoomIn.timingMode = .easeOut
        
        let zoomOut = SKAction.scale(to: 1.0, duration: 0.2)
        zoomOut.timingMode = .easeInEaseOut
        
        let pulse = SKAction.sequence([zoomIn, zoomOut])
        targetBox?.run(pulse)
        
    }
    
    // MARK: - Helpers
    
    private func TeardownUI() {
        let managedNames: Set<String> = ["timerLabel", "p1ScoreLabel", "p2ScoreLabel", "endLabel"]
        scene?.children
            .filter { managedNames.contains($0.name ?? "") || ($0.name?.contains("_foodbar_") == true) }
            .forEach { $0.removeFromParent() }
    }
}

// MARK: - UI HUD

private func CreateUICard(title: String, value: String, imageName: String, textColor: SKColor, iconName: String?, isIconLeft: Bool) -> (bgNode: SKSpriteNode, labelNode: SKLabelNode) {
    
    // Rectangle
    let bgNode = SKSpriteNode(imageNamed: imageName)
    bgNode.size = CGSize(width: 180, height: 180)
    
    // Title Text
    let titleLabel = SKLabelNode(fontNamed: "Nunito-ExtraBold")
    titleLabel.text = title
    titleLabel.fontSize = 12
    titleLabel.fontColor = textColor
    titleLabel.verticalAlignmentMode = .top
    titleLabel.position = CGPoint(x: 0, y: 22)
    titleLabel.zPosition = 3
    bgNode.addChild(titleLabel)
    
    // Number Text
    let valueLabel = SKLabelNode(fontNamed: "Nunito-Black")
    valueLabel.text = value
    valueLabel.fontSize = 32
    valueLabel.fontColor = textColor
    valueLabel.verticalAlignmentMode = .center
    valueLabel.position = CGPoint(x: 0, y: -10)
    valueLabel.zPosition = 4
    bgNode.addChild(valueLabel)
    
    // Icon Ompreng
    if let icon = iconName {
        let iconNode = SKSpriteNode(imageNamed: icon)
        iconNode.size = CGSize(width: 130, height: 130)
        iconNode.zPosition = 5
        
        // Posisikan menyembul keluar di kiri atau kanan
        let offsetX: CGFloat = isIconLeft ? -90 : 90
        iconNode.position = CGPoint(x: offsetX, y: 0)
        
        // Beri efek rotasi sedikit agar terlihat lebih dinamis dan bermain-main
        iconNode.zRotation = isIconLeft ? 0.2 : -0.2
        
        bgNode.addChild(iconNode)
    }
    
    return (bgNode, valueLabel)
}
