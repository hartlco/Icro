//
//  Created by martin on 10.08.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit

final class MainMenuBuilder {
    func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)

        let fileMenuCilden = [
            MainMenuKeyCommand.refresh.command,
            MainMenuKeyCommand.compose.command
        ]

        let reloadDataMenu = UIMenu(title: "File Menu",
                                    image: nil,
                                    identifier: UIMenu.Identifier("File Menu"),
                                    options: .displayInline,
                                    children: fileMenuCilden)

        let mainMenu = UIMenu(title: "Main Menu",
                              image: nil,
                              identifier: UIMenu.Identifier("Main Menu"),
                              options: .displayInline,
                              children: [MainMenuKeyCommand.settings.command])

        builder.insertChild(reloadDataMenu, atStartOfMenu: .file)
        builder.insertSibling(mainMenu, afterMenu: .about)
    }
}
