import UIKit

final class InfoRowView: UIView {
    private let valueLabel = LabelFactory.createDefaultLabel()
    private let titleLabel = LabelFactory.createTitleLabel()
    private let stackView = StackViewFactory.createHorizontalStackView(views: [], spacing: Spacing.small)
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(value: String) {
        valueLabel.text = value
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
