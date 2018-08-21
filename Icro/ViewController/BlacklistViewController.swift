//
//  BlacklistViewController.swift
//  Icro
//
//  Created by martin on 30.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

class BlacklistViewController: UIViewController {
    fileprivate let viewModel: BlacklistViewModel
    fileprivate let itemNavigator: ItemNavigator

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }
    }

    init(viewModel: BlacklistViewModel,
         itemNavigator: ItemNavigator) {
        self.viewModel = viewModel
        self.itemNavigator = itemNavigator
        super.init(nibName: "BlacklistViewController", bundle: nil)

        viewModel.update = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addWord))
        title = "Mute"
    }

    @objc private func addWord() {
        let alertController = UIAlertController(title: "Blacklist",
                                                message: "Add words or usernames to the blacklist",
                                                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Mute word"
        })
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_ action: UIAlertAction) -> Void in
            self?.viewModel.add(word: alertController.textFields?[0].text)
        })
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            print("Canelled")
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension BlacklistViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel.word(for: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.setTitle("Community guidelines / Report", for: .normal)
        button.addTarget(self, action: #selector(report), for: .touchUpInside)
        return button
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            viewModel.remove(at: indexPath)
        default:
            return
        }
    }

    @objc private func report() {
        itemNavigator.openCommunityGuidlines()
    }
}
