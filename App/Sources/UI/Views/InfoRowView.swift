import UIKit

final class InfoRowView: UIView {
    var value: String {
        get { valueLabel.text ?? "" }
        set { valueLabel.text = newValue }
    }
    
    private let title: String
    
    private let valueLabel = UIFactory.createDefaultLabel()
    private lazy var titleLabel = UIFactory.createTitleLabel(text: title)
    private lazy var stackView = UIFactory.createHorizontalStackView(views: [titleLabel, valueLabel], spacing: 5)
    
    init(title: String = "") {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
