import UIKit

final class InfoRowView: UIView {
    var value: String {
        get { valueLabel.text ?? "" }
        set { valueLabel.text = newValue }
    }
    
    private let title: String
    
    private let valueLabel = LabelFactory.createDefaultLabel()
    private lazy var titleLabel = LabelFactory.createTitleLabel(text: title)
    private lazy var stackView = StackViewFactory.createHorizontalStackView(views: [titleLabel, valueLabel], spacing: Spacing.small)
    
    init(title: String = "") {
        self.title = title
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
