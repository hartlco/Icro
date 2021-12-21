//
//  ComposeView.swift
//  Icro
//
//  Created by martinhartl on 11.12.21.
//  Copyright © 2021 Martin Hartl. All rights reserved.
//

import SwiftUI
import Style
import HighlightedTextEditor
import Kingfisher
import InsertLinkView
import SwiftUIX
import Introspect

struct ComposeView: View {
    @ObservedObject var viewModel: ComposeViewModel

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    @State var insertLinkActive = false
    @State var insertImageURLActive = false

    var didClose: (() -> Void)?

    init(viewModel: ComposeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if let item = viewModel.replyItem {
                    ReplyView(item: item)
                }
                HighlightedTextEditor(
                    text: $viewModel.text,
                    highlightRules: .markdown
                )
                if !viewModel.images.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewModel.images) { image in
                                KFImage(image.link)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                // TODO: Add image selection / deletion
                            }
                        }
                        .background(Color(uiColor: Style.Color.accentLight))
                    }
                    .padding()
                    .background(Color(uiColor: Style.Color.accentSuperLight))
                }
                VStack {
                    keyboardInputView
                }
                .background(Color(uiColor: Style.Color.accentLight))
                NavigationLink(
                    destination: insertLinkView,
                    isActive: $insertLinkActive
                ) {
                     EmptyView()
                }.hidden()
                NavigationLink(
                    destination: insertImageLinkView,
                    isActive: $insertImageURLActive
                ) {
                     EmptyView()
                }.hidden()
                .sheet(
                    isPresented: $viewModel.imagePickerActive) {
                        viewModel.imagePickerActive = false
                    } content: {
                        ImagePicker(
                            data: $viewModel.pickedImage,
                            encoding: .jpeg(compressionQuality: 0.8),
                            onCancel: {
                                viewModel.imagePickerActive = false
                            }
                        )
                    }
            }
            .navigationBarItems(
                leading:
                    Button(NSLocalizedString("COMPOSEVIEWCONTROLLER_CANCELBUTTON_TITLE", comment: "")) {
                        dismissView()
            }, trailing:
                    HStack {
                        if viewModel.uploading {
                            ProgressView()
                        }
                        Button(NSLocalizedString("KEYBOARDINPUTVIEW_POSTBUTTON_TITLE", comment: "")) {
                            Task {
                                do {
                                    try await viewModel.post()
                                } catch {
                                    // TODO: Proper error handling
                                }
                                dismissView()
                            }
                        }
                    }
            )
            // TODO: Add Drag/Drop interaction
            .navigationBarTitle(NSLocalizedString("COMPOSEVIEWCONTROLLER_TITLE", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var keyboardInputView: ComposeKeyboardInputView {
        var view = ComposeKeyboardInputView(viewModel: viewModel.composeKeyboardInputViewModel)
        view.didPressPostButton = {
            Task {
                do {
                    try await viewModel.post()
                } catch {
                    // TODO: Proper error handling
                }
                dismissView()
            }
        }

        view.didPressLinkButton = {
            insertLinkActive = true
        }

        view.didPressCancelButton = {
            viewModel.cancelImageUpload()
        }

        view.didPressImageURLMenu = {
            insertImageURLActive = true
        }

        view.didPressImageUploadMenu = {
            viewModel.imagePickerActive = true
        }

        return view
    }

    func dismissView() {
        didClose?()
        dismiss()
    }

    var insertLinkView: InsertLinkView {
        InsertLinkView { title, url in
            insertLinkActive = false

            guard let url = url else { return }

            viewModel.insertLink(url: url, title: title)
        }
    }

    var insertImageLinkView: InsertLinkView {
        InsertLinkView { title, url in
            insertImageURLActive = false

            guard let url = url else { return }

            viewModel.insertImage(image: .init(title: title ?? "", link: url))
        }
    }
}

private struct ReplyView: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading) {
            ItemView(item: item)
            Text(NSLocalizedString("COMPOSEVIEWCONTROLLER_TABLEVIEW_HEADER_TITLE", comment: ""))
                .font(.headline).bold()
        }
        .padding()
    }
}

private struct ItemView: View {
    let item: Item

    var body: some View {
        HStack(alignment: .top) {
            KFImage(item.author.avatar)
                .resizable()
                .renderingMode(.original)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                HStack {
                    Text(item.author.name)
                        .font(.headline)
                    Text(item.author.username ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text(item.htmlContent.attributedStringWithoutImages()?.string ?? "")
            }
        }
    }
}

#if DEBUG
struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ComposeViewModel(mode: .post)
        let imageViewModel = ComposeViewModel(
            mode: .shareImage(
                image: .init(
                    title: "Test",
                    link: URL(string: "https://hartl.co/log/2020-12-30t07-22-43-247z/57E09520-B1CA-4EF6-815F-9FDF9F34E941.jpg")!
                )
            )
        )

        let replyViewModel = ComposeViewModel(
            mode: .reply(item: Item.mock)
        )

        let shareURLViewModel = ComposeViewModel(
            mode: .shareURL(url: URL(string: "https://google.de")!,
                            title: "Google"))

        Group {
            ComposeView(viewModel: viewModel)
            ComposeView(viewModel: shareURLViewModel)
            ComposeView(viewModel: replyViewModel)
            ComposeView(viewModel: imageViewModel)
        }
    }
}
#endif
