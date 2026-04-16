import UIKit

class BaseListViewController<Item>: BaseViewController {
    var emptyStateText: String {
        return ""
    }
    
    var displayedItemsCount: Int {
        return min(items.count, settings.maxRecords)
    }
    
    private let settings: SettingsManager
    private var items: [Item] = []
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    init(settings: SettingsManager) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTableView() {
        tableView.dataSource = self as? UITableViewDataSource
        tableView.delegate = self as? UITableViewDelegate
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func updateUI() {
        tableView.reloadData()
        updateEmptyState()
        stopLoading()
        refreshControl.endRefreshing()
    }
    
    func updateEmptyState() {
        if items.isEmpty || settings.maxRecords == 0 {
            let label = UILabel()
            label.text = emptyStateText
            label.textAlignment = .center
            label.textColor = .gray
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func setItems(_ newItems: [Item]) {
        items = newItems
    }
    
    func getItem(at index: Int) -> Item {
        return items[index]
    }
    
    func addItem(_ item: Item) {
        guard settings.maxRecords > 0 else {
            return
        }
        items.insert(item, at: 0)
        tableView.reloadData()
        updateEmptyState()
    }
    
    func updateItem(_ item: Item, where condition: (Item) -> Bool) {
        if let index = items.firstIndex(where: condition) {
            items[index] = item
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func deleteItem(at index: Int) {
        items.remove(at: index)
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    @objc func refreshData() {
        updateUI()
    }
}
