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
            tableView.delegate = self
            tableView.dataSource = self
            tableView.doubleAction = #selector(doubleClick)
        }
    }



    private let viewModel: ListViewModel
    private let itemCellConfigurator: ListItemCellConfigurator
    private let itemNavigator: ItemNavigator

    init(listViewModel: ListViewModel,
         itemNavigator: ItemNavigator) {
        self.viewModel = listViewModel
        self.itemCellConfigurator = ListItemCellConfigurator(itemNavigator: itemNavigator)
        self.itemNavigator = itemNavigator
        super.init(nibName: "ListViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
       fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didFinishLoading = { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }

        
        viewModel.load()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.delegate = self
    }

    func refresh() {
        viewModel.load()
    }

    @IBAction private func reply(sender: Any) {
        guard let firstIndex = tableView.selectedRowIndexes.first else {
            return
        }

        let item = viewModel.item(for: firstIndex)

        itemNavigator.openReply(for: item)
    }

    @IBAction private func openConversation(sender: Any) {
        guard let firstIndex = tableView.selectedRowIndexes.first else {
                return
        }

        let item = viewModel.item(for: firstIndex)
        itemNavigator.openConversation(for: item)
    }

    @objc private func doubleClick() {
        itemNavigator.openConversation(for: viewModel.item(for: tableView.clickedRow))
    }
}

extension ListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if viewModel.numberOfSections > 1 {
            return viewModel.numberOfItems(in: 1)
        }
        return viewModel.numberOfItems(in: 0)
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return viewModel.item(for: row)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let itemCell = tableView.makeView(withIdentifier: ListItemCell.identifier, owner: self) as? ListItemCell else {
            fatalError("Cell could not be dequed")
        }
        let item = viewModel.item(for: row)
        itemCellConfigurator.configure(itemCell, forDisplaying: item)
        return itemCell
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let item = viewModel.item(for: row)
        let someWidth: CGFloat = tableView.bounds.size.width - 70
        let frame: NSRect = NSRect(x: 0, y: 0, width: someWidth, height: CGFloat.greatestFiniteMagnitude)
        let textView = resizingTextView
        resizingTextView.frame = frame

        textView.textStorage?.setAttributedString(item.content)
        textView.isHorizontallyResizable = false
        textView.sizeToFit()

        let imageHeight: CGFloat = item.images.isEmpty ? 0 : 160

        let height = textView.frame.size.height + 40 + imageHeight
        return height
    }
}

extension ListViewController: NSWindowDelegate {
    func windowDidEndLiveResize(_ notification: Notification) {
        tableView.reloadData()
    }
}
