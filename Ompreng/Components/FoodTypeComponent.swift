import UIKit

public enum DishType: String, CaseIterable {
    case rice
    case chicken
    case broccoli
    case apple
    case milk
    
    var displayName: String {
        switch self {
        case .rice:
            return "Rice"
        case .chicken:
            return "Chicken"
        case .broccoli:
            return "Broccoli"
        case .apple:
            return "Apple"
        case .milk:
            return "Milk"
        }
    }
    
    var color: UIColor {
        switch self {
        case .rice:
            return UIColor(red: 1.0, green: 0.98, blue: 0.8, alpha: 1.0) // Light beige
        case .chicken:
            return UIColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0) // Orange
        case .broccoli:
            return UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0) // Green
        case .apple:
            return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) // Red
        case .milk:
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // White
        }
    }
    
    static func random() -> DishType {
        return allCases.randomElement() ?? .rice
    }
}

public class FoodTypeComponent {
    let dishType: DishType
    
    init(dishType: DishType) {
        self.dishType = dishType
    }
}
