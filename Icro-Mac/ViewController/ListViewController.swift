//
//  ListViewController.swift
//  Icro-Mac
//

import Cocoa
import IcroKit_Mac

class ListViewController: NSViewController, NSMenuItemValidation {
    private var resizingTextView = NSTextView()

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "ReplyIdentifier"),
             NSUserInterfaceItemIdentifier(rawValue: "OpenConversationIdentifier"):
            return !tableView.selectedRowIndexes.isEmpty
        default:
            return true
        }
    }

    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            tableView.register(ListItemCell.nib, forIdentifier: ListItemCell.identifier)
            tableView.register(LoadMoreCell.nib, forIdentifier: LoadMoreCell.identifier)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.doubleAction = #selector(doubleClick)
        }
    }

    private let viewModel: ListViewModel
    private let itemCellConfigurator: ListItemCellConfigurator
    private let itemNavigator: ItemNavigator
    private let notificationCenter: NotificationCenter

    init(listViewModel: ListViewModel,
         itemNavigator: ItemNavigator,
         notificationCenter: NotificationCenter = .default) {
        self.viewModel = listViewModel
        self.itemCellConfigurator = ListItemCellConfigurator(itemNavigator: itemNavigator)
        self.itemNavigator = itemNavigator
        self.notificationCenter = notificationCenter
        super.init(nibName: "ListViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
       fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didFinishLoading = { [weak self] _ in
            guard let self = self else { return }
            if let newIndex = self.viewModel.numberOfUnreadItems {
                self.tableView.scrollRowToVisible(newIndex)
            }
            self.tableView.reloadData()
        }

        viewModel.load()
        notificationCenter.addObserver(self,
                                       selector: #selector(boundsDidChange(notification:)),
                                       name: NSView.boundsDidChangeNotification,
                                       object: tableView.enclosingScrollView?.contentView)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.delegate = self
    }

    func refresh() {
        viewModel.load()
    }

    @IBAction private func reply(sender: Any) {
        guard let firstIndex = tableView.selectedRowIndexes.first,
        case .item(let item) = viewModel.viewType(forRow: firstIndex) else {
            return
        }

        itemNavigator.openReply(for: item)
    }

    @IBAction private func openConversation(sender: Any) {
        guard let firstIndex = tableView.selectedRowIndexes.first,
        case .item(let item) = viewModel.viewType(forRow: firstIndex) else {
                return
        }

        itemNavigator.openConversation(for: item)
    }

    @objc private func doubleClick() {
        guard case .item(let item) = viewModel.viewType(forRow: tableView.clickedRow) else { return }

        itemNavigator.openConversation(for: item)
    }

    @objc private func boundsDidChange(notification: Notification) {
        let visibleRect = tableView.visibleRect
        let rows = tableView.rows(in: visibleRect)
        let index = rows.location

        switch viewModel.viewType(forRow: index) {
        case .item:
            viewModel.set(lastReadRow: index)
        default:
            return
        }
    }
}

extension ListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.numberOfItems()
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return viewModel.viewType(forRow: row)
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        switch viewModel.viewType(forRow: row) {
        case .item(let item):
            guard let itemCell = tableView.makeView(withIdentifier: ListItemCell.identifier, owner: self) as? ListItemCell else {
                fatalError("Cell could not be dequed")
            }
            itemCellConfigurator.configure(itemCell, forDisplaying: item)
            return itemCell
        case .loadMore:
            guard let loadMoreCell = tableView.makeView(withIdentifier: LoadMoreCell.identifier, owner: self) as? LoadMoreCell else {
                fatalError("Cell could not be dequed")
            }
            return loadMoreCell
        case .author:
            fatalError()
        }
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        switch viewModel.viewType(forRow: row) {
        case .item(let item):
            let someWidth = tableView.bounds.size.width - 70
            let frame: NSRect = NSRect(x: 0, y: 0, width: someWidth, height: CGFloat.greatestFiniteMagnitude)
            let textView = resizingTextView
            resizingTextView.frame = frame

            textView.textStorage?.setAttributedString(item.content)
            textView.isHorizontallyResizable = false
            textView.sizeToFit()

            let imageHeight = item.media.isEmpty ? 0 : 160

            let height = textView.frame.size.height + 40 + imageHeight
            return height
        default:
            return 60
        }
    }
}

extension ListViewController: NSWindowDelegate {
    func windowDidEndLiveResize(_ notification: Notification) {
        tableView.reloadData()
    }
}
