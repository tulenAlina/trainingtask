import UIKit

protocol MainMenuViewInputProtocol: AnyObject {}

protocol MainMenuViewOutputProtocol {
    func didTapButton(item: MenuItem)
}

final class MainMenuViewController: UIViewController, MainMenuViewInputProtocol {
    var output: MainMenuViewOutputProtocol
    
    private let menuItems = MenuItem.allCases
    
    private lazy var buttons: [UIButton] = ButtonFactory.createMenuButtons(from: menuItems, target: self, action: #selector(actionButtonTapped))
    private lazy var contentScrollView = ScrollableStackView(views: buttons, spacing: 15)
    
    init(presenter: MainMenuViewOutputProtocol) {
        output = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Private
private extension MainMenuViewController {
    func setupView() {
        view.backgroundColor = .white
        title = Localized.mainMenu
        setupContentView()
        setupButtons()
    }
    
    func setupContentView() {
        view.addSubview(contentScrollView)
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }
    
    func setupButtons() {
        buttons.forEach { button in
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05)
            ])
        }
    }
    
    @objc func actionButtonTapped(_ sender: UIButton) {
        guard let item = MenuItem(rawValue: sender.tag) else {
            return
        }
        output.didTapButton(item: item)
    }
}
