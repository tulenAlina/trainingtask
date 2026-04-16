import UIKit

final class StatusView: UIView {
    var status: TaskStatus {
        get {
            switch statusLabel.text {
            case TaskStatus.notStarted.rawValue.localized:
                return .notStarted
            case TaskStatus.inProgress.rawValue.localized:
                return .inProgress
            case TaskStatus.completed.rawValue.localized:
                return .completed
            case TaskStatus.postponed.rawValue.localized:
                return .postponed
            default:
                return .notStarted
            }
        }
        set {
            statusLabel.text = newValue.rawValue.localized
            updateAppearance()
        }
    }
    
    private let statusView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAppearance() {
        switch status {
        case .notStarted:
            statusLabel.textColor = .red
            statusView.layer.borderColor = UIColor.red.cgColor
            statusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        case .inProgress:
            statusLabel.textColor = .blue
            statusView.layer.borderColor = UIColor.blue.cgColor
            statusView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        case .completed:
            statusLabel.textColor = .green
            statusView.layer.borderColor = UIColor.green.cgColor
            statusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        case .postponed:
            statusLabel.textColor = .orange
            statusView.layer.borderColor = UIColor.orange.cgColor
            statusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        }
    }
    
    private func setupUI() {
        addSubview(statusView)
        statusView.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusView.topAnchor.constraint(equalTo: topAnchor),
            statusView.bottomAnchor.constraint(equalTo: bottomAnchor),
            statusView.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor, constant: 5),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: -5),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 5),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -5)
        ])
    }
}
