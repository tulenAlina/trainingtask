import UIKit

enum Spacing {
    static let small: CGFloat = 5
    static let medium: CGFloat = 10
    static let large: CGFloat = 15
    static let extraLarge: CGFloat = 20
}

enum Margins {
    static let cardInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
}

enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 10
    static let large: CGFloat = 16
}

enum BorderWidth {
    static let thin: CGFloat = 0.5
    static let normal: CGFloat = 1
}

enum Colors {
    static let validBorder = UIColor(white: 0.8, alpha: 1)
    static let invalidBorder = UIColor.red
    
    static let notStartedText = UIColor.red
    static let notStartedBackground = UIColor.systemRed.withAlphaComponent(0.1)
    
    static let inProgressText = UIColor.blue
    static let inProgressBackground = UIColor.systemBlue.withAlphaComponent(0.1)
    
    static let completedText = UIColor(red: 0.3, green: 0.65, blue: 0.3, alpha: 1)
    static let completedBackground = UIColor.systemGreen.withAlphaComponent(0.1)
    
    static let postponedText = UIColor.orange
    static let postponedBackground = UIColor.systemOrange.withAlphaComponent(0.1)
    
    static let cardBackground = UIColor.secondarySystemBackground
}

enum Shadow {
    static let color = UIColor.black.cgColor
    static let opacity: Float = 0.05
    static let offset = CGSize(width: 0, height: 2)
    static let radius: CGFloat = 4
}

enum FontSize {
    static let caption: CGFloat = 12
    static let body: CGFloat = 14
    static let title: CGFloat = 16
    static let headline: CGFloat = 18
    static let largeTitle: CGFloat = 24
}

enum Fonts {
    static let caption = UIFont.systemFont(ofSize: FontSize.caption)
}
