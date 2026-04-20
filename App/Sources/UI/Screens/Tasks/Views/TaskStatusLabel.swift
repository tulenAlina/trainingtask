import UIKit

final class TaskStatusLabel: UIView {
    var status: TaskStatus = .notStarted {
        didSet {
            statusLabel.text = status.rawValue.localized
            configure(with: status)
        }
    }
    
    private let statusView: UIView = {
        let view = UIView()
        view.layer.borderWidth = BorderWidth.thin
        view.layer.cornerRadius = CornerRadius.medium
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.caption
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with status: TaskStatus) {
        switch status {
        case .notStarted:
            statusLabel.textColor = Colors.notStartedText
            statusView.layer.borderColor = Colors.notStartedText.cgColor
            statusView.backgroundColor = Colors.notStartedBackground
        case .inProgress:
            statusLabel.textColor = Colors.inProgressText
            statusView.layer.borderColor = Colors.inProgressText.cgColor
            statusView.backgroundColor = Colors.inProgressBackground
        case .completed:
            statusLabel.textColor = Colors.completedText
            statusView.layer.borderColor = Colors.completedText.cgColor
            statusView.backgroundColor = Colors.completedBackground
        case .postponed:
            statusLabel.textColor = Colors.postponedText
            statusView.layer.borderColor = Colors.postponedText.cgColor
            statusView.backgroundColor = Colors.postponedBackground
        }
    }
    
    private func setupView() {
        addSubview(statusView)
        statusView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusView.topAnchor.constraint(equalTo: topAnchor),
            statusView.bottomAnchor.constraint(equalTo: bottomAnchor),
            statusView.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor, constant: Spacing.small),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: -Spacing.small),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: Spacing.small),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -Spacing.small)
        ])
    }
}
