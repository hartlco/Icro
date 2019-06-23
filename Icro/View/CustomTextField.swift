//
//  Created by Martin Hartl on 22.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct CustomTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var didBecomeFirstResponder = false
        var didReturn: () -> Void

        init(text: Binding<String>,
             didReturn: @escaping () -> Void) {
            $text = text
            self.didReturn = didReturn
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            didReturn()
            didBecomeFirstResponder = false
            textField.resignFirstResponder()
            return true
        }
    }

    @Binding var text: String
    var placeholder: String? = nil
    var isFirstResponder: Bool = false
    var didReturn: () -> Void = { }

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text,
                           didReturn: didReturn)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        uiView.placeholder = placeholder
        context.coordinator.didReturn = didReturn
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
