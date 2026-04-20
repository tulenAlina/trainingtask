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
        stack.layoutMargins = Margins.cardInsets
        stack.backgroundColor = Colors.cardBackground
        stack.layer.cornerRadius = CornerRadius.large
        stack.layer.shadowColor = Shadow.color
        stack.layer.shadowOpacity = Shadow.opacity
        stack.layer.shadowOffset = Shadow.offset
        stack.layer.shadowRadius = Shadow.radius
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
        workTimeRaw.value = workTime
        startDateRaw.value = startDate
        endDateRaw.value = endDate
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
