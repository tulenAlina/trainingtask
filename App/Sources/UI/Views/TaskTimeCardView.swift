import UIKit

final class TaskTimeCardView: UIView {
    private let workTimeTitleLabel = UIFactory.createTitleLabel(text: Localized.hoursLabel)
    private let startDateTitleLabel = UIFactory.createTitleLabel(text: Localized.startDateLabel)
    private let endDateTitleLabel = UIFactory.createTitleLabel(text: Localized.endDateLabel)
    
    private let workTimeLabel = UILabel()
    private let startDateLabel = UILabel()
    private let endDateLabel = UILabel()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = 16
        stack.layer.shadowColor = UIColor.black.cgColor
        stack.layer.shadowOpacity = 0.05
        stack.layer.shadowOffset = CGSize(width: 0, height: 2)
        stack.layer.shadowRadius = 4
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
    
    func configure(with task: ProjectTask) {
        workTimeLabel.text = "\(task.workTime)"
        startDateLabel.text =  DateHelper.string(from: task.startDate)
        endDateLabel.text = DateHelper.string(from: task.endDate)
    }
    
    private func setupView() {
        setupLabels()
        setupRows()
        setupContentView()
    }
    
    private func setupLabels() {
        [workTimeLabel, startDateLabel, endDateLabel].forEach { label in
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupRows() {
        let workTimeRow = UIStackView(arrangedSubviews: [workTimeTitleLabel, workTimeLabel])
        let startDateRow = UIStackView(arrangedSubviews: [startDateTitleLabel, startDateLabel])
        let endDateRow = UIStackView(arrangedSubviews: [endDateTitleLabel, endDateLabel])
        
        [workTimeRow, startDateRow, endDateRow].forEach { row in
            row.axis = .horizontal
            row.spacing = 5
            row.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(row)
        }
    }
    
    private func setupContentView() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
