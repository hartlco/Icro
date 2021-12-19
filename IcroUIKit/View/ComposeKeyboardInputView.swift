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
                HStack {
                    Text("KEYBOARDINPUTVIEW_LINKBUTTON_TTILE")
                        .foregroundColor(Color(uiColor: Style.Color.accent))
                }
            })
            .tint(Color(uiColor: Style.Color.buttonColor))
            .buttonStyle(.borderedProminent)
            if !viewModel.imageButtonHidden {
                Menu("KEYBOARDINPUTVIEW_IMAGEBUTTON_TITLE") {
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
                }
                .padding([.top, .bottom], 6.5)
                .padding([.leading, .trailing], 9.0)
                .tint(Color(uiColor: Style.Color.accent))
                .background(Color(uiColor: Style.Color.buttonColor))
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 6.0, style: .continuous))
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
                .foregroundColor(Color(uiColor: Style.Color.secondaryTextColor))
                .font(.footnote)
            Button(action: {
                didPressPostButton?()
            }, label: {
                HStack {
                    Text("KEYBOARDINPUTVIEW_POSTBUTTON_TITLE")
                        .foregroundColor(Color(uiColor: Style.Color.main))
                        .fontWeight(.medium)
                }
            })
            .tint(Color(uiColor: Style.Color.buttonColor))
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.postButtonEnabled)
        }
        .padding(6.0)
        .background(Color(uiColor: Style.Color.accentLight))
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
