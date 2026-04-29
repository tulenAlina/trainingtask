import UIKit

final class TaskStatusLabel: UIView {
    private let statusView: UIView = {
        let view = UIView()
        view.layer.borderWidth = BorderWidth.thin
        view.layer.cornerRadius = CornerRadius.small
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
        statusLabel.text = status.rawValue.localized
        
        switch status {
            
        case .notStarted:
            statusLabel.textColor = Colors.statusNotStarted
            statusView.layer.borderColor = Colors.statusNotStarted.cgColor
            statusView.backgroundColor = Colors.statusNotStartedBackground
        case .inProgress:
            statusLabel.textColor = Colors.statusInProgress
            statusView.layer.borderColor = Colors.statusInProgress.cgColor
            statusView.backgroundColor = Colors.statusInProgressBackground
        case .completed:
            statusLabel.textColor = Colors.statusCompleted
            statusView.layer.borderColor = Colors.statusCompleted.cgColor
            statusView.backgroundColor = Colors.statusCompletedBackground
        case .postponed:
            statusLabel.textColor = Colors.statusPostponed
            statusView.layer.borderColor = Colors.statusPostponed.cgColor
            statusView.backgroundColor = Colors.statusPostponedBackground
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
