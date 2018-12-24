//
//  Created by martin on 08.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

class ProfileTableViewCell: UITableViewCell {
    static let identifier = "ProfileTableViewCell"

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.adjustsFontForContentSizeCategory = true
            nameLabel.font = Font().name
        }
    }
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.adjustsFontForContentSizeCategory = true
            usernameLabel.font = Font().username
        }
    }
    @IBOutlet weak var profileButton: UIButton! {
        didSet {
            profileButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }
    @IBOutlet weak var bioLabel: UILabel! {
        didSet {
            bioLabel.adjustsFontForContentSizeCategory = true
            bioLabel.font = Font().body
        }
    }
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            followButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }
    @IBOutlet weak var followingButton: UIButton! {
        didSet {
            followingButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var contentContainer: UIView!

    var followPressed: (() -> Void)?
    var followingPressed: (() -> Void)?
    var profilePressed: (() -> Void)?
    var avatarPressed: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        appearanceSetup()
        let avatarTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewPressed(_:)))
        avatarImageView.addGestureRecognizer(avatarTapRecognizer)
        followButton.setTitle(NSLocalizedString("PROFILETABLEVIEWCELL_FOLLOWBUTTON_TITLE", comment: ""), for: .normal)
        followingButton.setTitle(NSLocalizedString("PROFILETABLEVIEWCELL_FOLLOWINGBUTTON_TITLE", comment: ""), for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        appearanceSetup()
        followButton.isHidden = false
        followingButton.isHidden = false
        followButton.isEnabled = false
        followingButton.isEnabled = false
    }

    @IBAction private func followButtonPressed(_ sender: Any) {
        followPressed?()
    }

    @IBAction private func profileButtonPressed(_ sender: Any) {
        profilePressed?()
    }

    @IBAction func followingButtonPressed(_ sender: Any) {
        followingPressed?()
    }

    @objc private func avatarImageViewPressed(_ sender: Any) {
        avatarPressed?()
    }

    private func appearanceSetup() {
        backgroundColor = Color.backgroundColor
        contentContainer.backgroundColor = Color.accentLight
        usernameLabel.textColor = Color.textColor
        nameLabel.textColor = Color.textColor
        bioLabel.textColor = Color.textColor
        followButton.backgroundColor = Color.buttonColor
        followingButton.backgroundColor = Color.buttonColor
    }
}
