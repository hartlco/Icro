//
//  ComposeKeyboardInputView.swift
//  Icro
//
//  Created by martinhartl on 05.12.21.
//  Copyright © 2021 Martin Hartl. All rights reserved.
//

import Combine
import SwiftUI

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
        HStack(spacing: 4) {
            Button(action: {
                didPressLinkButton?()
            }, label: {
                Label("KEYBOARDINPUTVIEW_LINKBUTTON_TTILE", systemImage: "link")
                    .labelStyle(.iconOnly)
            })
            .frame(width: 44, height: 44)
            .accessibilityLabel(Text("KEYBOARDINPUTVIEW_LINKBUTTON_TTILE"))
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
                .frame(width: 44, height: 44)
                .disabled(!viewModel.imageButtonEnabled)
            }
            Spacer()
            if !viewModel.progressHidden {
                ProgressView(value: viewModel.progress, total: 1)
                    .frame(maxWidth: 64)
                Button {
                    didPressCancelButton?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .frame(width: 44, height: 44)
            }
            Text(viewModel.characterCountText)
                .foregroundStyle(.secondary)
                .font(.caption.monospacedDigit())
                .accessibilityHidden(viewModel.characterCountText.isEmpty)
            Button(action: {
                didPressPostButton?()
            }, label: {
                Text("KEYBOARDINPUTVIEW_POSTBUTTON_TITLE")
                    .font(.subheadline.weight(.semibold))
            })
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .disabled(!viewModel.postButtonEnabled)
        }
        .font(.system(size: 18, weight: .medium))
        .foregroundStyle(.primary)
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .glassEffect(.regular, in: Capsule())
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
