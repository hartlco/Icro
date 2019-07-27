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
        if #available(iOS 13.0, *) {
             let activeScene = UIApplication.shared.connectedScenes.first {
                 $0.activationState == .foregroundActive
             }

              guard let windowScene = activeScene as? UIWindowScene else {
                 fatalError("No active scene")
             }

              return windowScene.windows.first!
         } else {
             fatalError()
         }
    }

    static var isPortraitOnly: Bool {

        let orientations = UIApplication.shared.supportedInterfaceOrientations(for: nil)

        return !(orientations.contains(.landscapeLeft) || orientations.contains(.landscapeRight) || orientations.contains(.landscape))
    }
}
