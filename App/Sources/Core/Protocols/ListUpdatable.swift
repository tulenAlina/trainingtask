import UIKit

protocol ListUpdatable: AnyObject {
    associatedtype ItemType
    var items: [ItemType] { get set }
    var tableView: UITableView { get }
    var settings: SettingsManager { get }
    var emptyStateText: String { get }
}

extension ListUpdatable {
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
    
    func addItem(_ item: ItemType) {
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
    
    func updateItem(_ item: ItemType, where condition: (ItemType) -> Bool) {
        if let index = items.firstIndex(where: condition) {
            items[index] = item
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
