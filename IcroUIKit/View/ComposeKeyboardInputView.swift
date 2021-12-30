//
//  ComposeKeyboardInputView.swift
//  Icro
//
//  Created by martinhartl on 05.12.21.
//  Copyright © 2021 Martin Hartl. All rights reserved.
//

import Combine
import SwiftUI
import Style

final class ComposeKeyboardInputViewModel: ObservableObject {
    @Published var characterCountText = ""
    @Published var postButtonEnabled = false
    @Published var imageButtonEnabled = false
    @Published var imageButtonHidden = false
    @Published var progressHidden = false
    @Published var progress: Float = 0.0

    func update(for text: String, numberOfImages: Int, imageState: ImageState, hidesImageButton: Bool) {
        if text.isEmpty {
            characterCountText = ""
        } else {
            characterCountText = "\(text.count)c"
        }

        imageButtonHidden = hidesImageButton

        switch imageState {
        case .idle:
            progressHidden = true
            postButtonEnabled = text.count > 0 || numberOfImages > 0
            imageButtonEnabled = true
        case .uploading(let progress):
            postButtonEnabled = false
            imageButtonEnabled = false
            progressHidden = false
            self.progress = progress
        }
    }
}

struct ComposeKeyboardInputView: View {
    @ObservedObject private var viewModel: ComposeKeyboardInputViewModel

    var didPressLinkButton: (() -> Void)?
    var didPressCancelButton: (() -> Void)?
    var didPressPostButton: (() -> Void)?

    var didPressImageURLMenu: (() -> Void)?
    var didPressImageUploadMenu: (() -> Void)?

    init(viewModel: ComposeKeyboardInputViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            Button(action: {
                didPressLinkButton?()
            }, label: {
                Label("KEYBOARDINPUTVIEW_LINKBUTTON_TTILE", systemImage: "link")
                    .labelStyle(.iconOnly)
            })
            if !viewModel.imageButtonHidden {
                Menu {
                    Button {
                        didPressImageURLMenu?()
                    } label: {
                        Label("COMPOSENAVIGATOR_OPENIMAGEALERT_URLACTION",
                              systemImage: "link")
                    }
                    if viewModel.imageButtonEnabled {
                        Button {
                            didPressImageUploadMenu?()
                        } label: {
                            Label("COMPOSENAVIGATOR_OPENIMAGEALERT_UPLOADACTION",
                                  systemImage: "photo")
                        }
                    }
                } label: {
                    Label("KEYBOARDINPUTVIEW_IMAGEBUTTON_TITLE", systemImage: "photo")
                        .labelStyle(.iconOnly)
                }

                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.imageButtonEnabled)
            }
            Spacer()
            if !viewModel.progressHidden {
                ProgressView(value: viewModel.progress, total: 1)
                Button {
                    didPressCancelButton?()
                } label: {
                    Image("cancel", bundle: nil)
                }
            }

            Spacer()
            Text(viewModel.characterCountText)
                .foregroundColor(Style.Color.secondaryTextColor.swiftUIColor)
                .font(.footnote)
            Button(action: {
                didPressPostButton?()
            }, label: {
                HStack {
                    Text("KEYBOARDINPUTVIEW_POSTBUTTON_TITLE")
                        .foregroundColor(Style.Color.main.swiftUIColor)
                        .fontWeight(.medium)
                }
            })
            .tint(Style.Color.buttonColor.swiftUIColor)
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.postButtonEnabled)
        }
        .padding(6.0)
        .background(Style.Color.accentLight.swiftUIColor)
    }
}

struct ComposeKeyboardInputView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ComposeKeyboardInputViewModel()

        let view =  ComposeKeyboardInputView(viewModel: viewModel)
        viewModel.update(
            for: "Hi123",
            numberOfImages: 1,
            imageState: .idle,
            hidesImageButton: false
        )
        return view
    }
}
