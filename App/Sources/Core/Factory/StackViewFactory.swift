import UIKit

enum StackViewFactory {
    static func createVerticalFieldGroup(labelText: String, inputView: UIView) -> UIStackView {
        let label = LabelFactory.createSecondaryLabel()
        label.text = labelText
        let stack = UIStackView(arrangedSubviews: [label, inputView])
        stack.axis = .vertical
        stack.spacing = Spacing.small
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    static func createVerticalStackView(views: [UIView], spacing: CGFloat) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    static func createHorizontalStackView(views: [UIView], spacing: CGFloat) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
}
