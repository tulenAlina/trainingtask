import UIKit

enum ButtonFactory {
    static func createDefaultButton(text: String) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(Colors.primaryText, for: .normal)
        button.backgroundColor = ButtonStyle.defaultBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    static func createSecondaryButton(text: String) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(Colors.primaryText, for: .normal)
        button.backgroundColor = Colors.secondaryBackground
        button.layer.borderWidth = BorderWidth.thin
        button.layer.borderColor = ButtonStyle.border.cgColor
        button.layer.cornerRadius = ButtonStyle.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    static func createDeleteButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(Localized.delete, for: .normal)
        button.setTitleColor(Colors.invalidBorder, for: .normal)
        button.backgroundColor = ButtonStyle.deleteBackground
        button.layer.borderWidth = BorderWidth.thin
        button.layer.borderColor = Colors.invalidBorder.cgColor
        button.layer.cornerRadius = ButtonStyle.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    static func createClearButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(Localized.clear, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    static func createMenuButtons(from items: [MenuItem], target: Any, action: Selector) -> [UIButton] {
        var buttons: [UIButton] = []
        for item in items {
            let button = ButtonFactory.createDefaultButton(text: item.title)
            button.tag = item.rawValue
            button.addTarget(target, action: action, for: .touchUpInside)
            buttons.append(button)
        }
        return buttons
    }
}
