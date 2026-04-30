import UIKit

final class TaskTimeCardView: UIView {
    private let workTimeRaw = InfoRowView(title: Localized.hoursLabel)
    private let startDateRaw = InfoRowView(title: Localized.startDateLabel)
    private let endDateRaw = InfoRowView(title: Localized.endDateLabel)
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.large
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = CardStyle.insets
        stack.backgroundColor = CardStyle.backgroundColor
        stack.layer.cornerRadius = CardStyle.cornerRadius
        stack.layer.shadowColor = CardStyle.shadowColor
        stack.layer.shadowOpacity = CardStyle.shadowOpacity
        stack.layer.shadowOffset = CardStyle.shadowOffset
        stack.layer.shadowRadius = CardStyle.shadowRadius
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(workTime: String, startDate: String, endDate: String) {
        workTimeRaw.configure(workTime)
        startDateRaw.configure(startDate)
        endDateRaw.configure(endDate)
    }
    
    private func setupView() {
        stackView.addArrangedSubview(workTimeRaw)
        stackView.addArrangedSubview(startDateRaw)
        stackView.addArrangedSubview(endDateRaw)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
