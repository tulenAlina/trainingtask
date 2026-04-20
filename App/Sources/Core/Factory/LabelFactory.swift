import UIKit

enum LabelFactory {
    static func createDefaultLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createSecondaryLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = Colors.secondaryText
        label.font = Fonts.secondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createTitleLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Fonts.title
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createTitleLargeLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.font = Fonts.largeTitle
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
