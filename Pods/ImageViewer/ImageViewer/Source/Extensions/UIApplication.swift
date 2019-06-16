//
//  UIApplication.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 19/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UIApplication {

    static var applicationWindow: UIWindow {
        let activeScene = UIApplication.shared.connectedScenes.first {
            $0.activationState == .foregroundActive
        }

        guard let windowScene = activeScene as? UIWindowScene else {
            fatalError("No active scene")
        }

        return windowScene.windows.first!
    }

    static var isPortraitOnly: Bool {

        let orientations = UIApplication.shared.supportedInterfaceOrientations(for: nil)

        return !(orientations.contains(.landscapeLeft) || orientations.contains(.landscapeRight) || orientations.contains(.landscape))
    }
}
