import UIKit

enum Spacing {
    static let small: CGFloat = 5
    static let medium: CGFloat = 10
    static let large: CGFloat = 15
    static let extraLarge: CGFloat = 20
}

enum BorderWidth {
    static let thin: CGFloat = 0.5
    static let normal: CGFloat = 1
}

enum Colors {
    static let primaryText = UIColor.black
    static let secondaryText = UIColor.secondaryLabel
    
    static let border = UIColor(white: 0.8, alpha: 1)
    static let invalidBorder = UIColor.red
    
    static let secondaryBackground = UIColor(white: 0.95, alpha: 1)
}

enum Fonts {
    static let caption = UIFont.systemFont(ofSize: 12, weight: .regular)
    static let secondary = UIFont.systemFont(ofSize: 14, weight: .medium)
    static let title = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let largeTitle = UIFont.systemFont(ofSize: 18, weight: .semibold)
}

enum ButtonStyle {
    static let defaultBackground = UIColor.lightGray
    static let deleteBackground = UIColor.systemRed.withAlphaComponent(0.1)
    static let border = UIColor.darkGray
    static let cornerRadius: CGFloat = 12
}
enum TaskStatusStyle {
    static func color(for status: TaskStatus) -> UIColor {
        switch status {
            
        case .notStarted: return .red
        case .inProgress: return .blue
        case .completed: return UIColor(red: 0.3, green: 0.65, blue: 0.3, alpha: 1)
        case .postponed: return .orange
        }
    }
    
    static func backgroundColor(for status: TaskStatus) -> UIColor {
        return color(for: status).withAlphaComponent(0.1)
    }
    
    static let cornerRadius: CGFloat = 10
}

enum CardStyle {
    static let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    static let cornerRadius: CGFloat = 16
    static let backgroundColor = UIColor.secondarySystemBackground
    static let shadowColor = UIColor.black.cgColor
    static let shadowOpacity: Float = 0.05
    static let shadowOffset = CGSize(width: 0, height: 2)
    static let shadowRadius: CGFloat = 4
}
