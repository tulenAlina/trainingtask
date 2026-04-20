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
    static let small: CGFloat = 10
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
}

enum BorderWidth {
    static let thin: CGFloat = 0.5
    static let normal: CGFloat = 1
}

enum Colors {
    static let primaryText = UIColor.black
    static let secondaryText = UIColor.secondaryLabel
    
    static let statusNotStarted = UIColor.red
    static let statusInProgress = UIColor.blue
    static let statusCompleted = UIColor(red: 0.3, green: 0.65, blue: 0.3, alpha: 1)
    static let statusPostponed = UIColor.orange
    
    static let validBorder = UIColor(white: 0.8, alpha: 1)
    static let invalidBorder = UIColor.red
    static let secondaryButtonBorder = UIColor.darkGray
    
    static let statusNotStartedBackground = UIColor.systemRed.withAlphaComponent(0.1)
    static let statusInProgressBackground = UIColor.systemBlue.withAlphaComponent(0.1)
    static let statusCompletedBackground = UIColor.systemGreen.withAlphaComponent(0.1)
    static let statusPostponedBackground = UIColor.systemOrange.withAlphaComponent(0.1)
    static let cardBackground = UIColor.secondarySystemBackground
    static let defaultButtonBackground = UIColor.lightGray
    static let deleteButtonBackground = UIColor.systemRed.withAlphaComponent(0.1)
    static let secondaryBackground = UIColor(white: 0.95, alpha: 1)
}

enum Shadow {
    static let color = UIColor.black.cgColor
    static let opacity: Float = 0.05
    static let offset = CGSize(width: 0, height: 2)
    static let radius: CGFloat = 4
}

enum FontSize {
    static let caption: CGFloat = 12
    static let secondary: CGFloat = 14
    static let title: CGFloat = 16
    static let largeTitle: CGFloat = 18
}

enum FontWeight {
    static let regular: UIFont.Weight = .regular
    static let medium: UIFont.Weight = .medium
    static let semibold: UIFont.Weight = .semibold
    static let bold: UIFont.Weight = .bold
}

enum Fonts {
    static let caption = UIFont.systemFont(ofSize: FontSize.caption, weight: FontWeight.regular)
    static let secondary = UIFont.systemFont(ofSize: FontSize.secondary, weight: FontWeight.medium)
    static let title = UIFont.systemFont(ofSize: FontSize.title, weight: FontWeight.semibold)
    static let largeTitle = UIFont.systemFont(ofSize: FontSize.largeTitle, weight: FontWeight.semibold)
}
