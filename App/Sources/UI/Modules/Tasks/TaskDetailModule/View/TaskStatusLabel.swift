import UIKit

final class TaskStatusLabel: UIView {
    private let statusView: UIView = {
        let view = UIView()
        view.layer.borderWidth = BorderWidth.thin
        view.layer.cornerRadius = TaskStatusStyle.cornerRadius
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
        statusLabel.textColor = TaskStatusStyle.color(for: status)
        statusView.layer.borderColor = TaskStatusStyle.color(for: status).cgColor
        statusView.backgroundColor = TaskStatusStyle.backgroundColor(for: status)
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
