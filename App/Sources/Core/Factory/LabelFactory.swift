import UIKit

enum LabelFactory {
    static func createDefaultLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.textColor = Colors.secondaryText
        label.font = Fonts.secondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = Fonts.title
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createTitleLargeLabel() -> UILabel {
        let label = UILabel()
        label.font = Fonts.largeTitle
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
