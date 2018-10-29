//
//  TabViewController.swift
//  Icro-Mac
//

import Cocoa
import IcroKit_Mac

class TabViewController: NSViewController {
    var didSelectTab: ((ListViewModel) -> Void)?

    private let viewModels = [
        ListViewModel(type: .timeline),
        ListViewModel(type: .mentions),
        ListViewModel(type: .favorites),
        ListViewModel(type: .discover),
        ListViewModel(type: .username(username: "hartlco"))
    ]

    @IBOutlet weak var outlineView: NSOutlineView! {
        didSet {
            outlineView.dataSource = self
            outlineView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.reloadData()
        outlineView.selectionHighlightStyle = .none
        outlineView.selectRowIndexes([0], byExtendingSelection: false)
    }

    override func viewDidAppear() {
        didSelectTab?(viewModels[0])
        highlightTab(at: 0)
    }

    func selectTab(index: Int) {
        outlineView.selectRowIndexes([index], byExtendingSelection: false)
        didSelectTab?(viewModels[index])
        highlightTab(at: index)
    }

    fileprivate func highlightTab(at index: Int) {
        for viewModelIndex in 0..<viewModels.count {
            guard let cell = outlineView.view(atColumn: 0, row: viewModelIndex, makeIfNecessary: false) as? NSTableCellView else { return }
            if viewModelIndex == index {
                cell.textField?.textColor = Color.main
            } else {
                cell.textField?.textColor = .black
            }
        }
    }
}

extension TabViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return viewModels.count
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        guard let viewModel = item as? ListViewModel else {
            return nil
        }

        return viewModel
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return viewModels[index]
    }
}

extension TabViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let viewModel = item as? ListViewModel else {
            fatalError()
        }

        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TabCell"), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = viewModel.title
        cell?.textField?.textColor = .black
        return cell
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        guard let viewModel = item as? ListViewModel else {
            return false
        }

        let row = outlineView.row(forItem: item)
        highlightTab(at: row)
        didSelectTab?(viewModel)
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 48
    }
}
