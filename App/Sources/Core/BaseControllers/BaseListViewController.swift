import UIKit

class BaseListViewController<Item>: BaseViewController {
    var settings: SettingsManager
    var items: [Item] = []
    var tableView = UITableView()
    var refreshControl = UIRefreshControl()
    var emptyStateText: String { return "" }

    init(settings: SettingsManager) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateEmptyState() {
        if items.isEmpty {
            let label = UILabel()
            label.text = emptyStateText
            label.textAlignment = .center
            label.textColor = .gray
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func addItem(_ item: Item) {
        let maxRecords = settings.maxRecords
        let lastRowIndexWithinLimit = maxRecords - 1
        let lastIndexPathWithinLimit = IndexPath(row: lastRowIndexWithinLimit, section: 0)
        let firstIndexPath = IndexPath(row: 0, section: 0)
        
        guard settings.maxRecords > 0 else { return }
        
        if items.count >= maxRecords {
            items.removeLast()
            tableView.deleteRows(at: [lastIndexPathWithinLimit], with: .automatic)
        }
        items.insert(item, at: 0)
        tableView.insertRows(at: [firstIndexPath], with: .automatic)
        updateEmptyState()
    }
    
    func updateItem(_ item: Item, where condition: (Item) -> Bool) {
        if let index = items.firstIndex(where: condition) {
            items[index] = item
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
