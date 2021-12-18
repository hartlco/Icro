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

struct ComposeView: View {
    @ObservedObject var viewModel: ComposeViewModel

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    @State var insertLinkActive = false

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
                NavigationLink(destination:
                   insertLinkView,
                   isActive: $insertLinkActive) {
                     EmptyView()
                }.hidden()
            }
            .navigationBarItems(
                leading:
                    Button("COMPOSEVIEWCONTROLLER_CANCELBUTTON_TITLE") {
                        dismiss()
            }, trailing:
                    HStack {
                        if viewModel.uploading {
                            ProgressView()
                        }
                        Button("KEYBOARDINPUTVIEW_POSTBUTTON_TITLE") {
                            viewModel.post { error in
                                // TODO: Show Error
                                // TODO: Dismiss
                            }
                        }
                    }
            )
            .navigationBarTitle("COMPOSEVIEWCONTROLLER_TITLE")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var keyboardInputView: ComposeKeyboardInputView {
        var view = ComposeKeyboardInputView(viewModel: viewModel.composeKeyboardInputViewModel)
        view.didPressPostButton = {
            viewModel.post(completion: { error in
                // TODO: Show Error
                // TODO: Dismiss
            })
        }

        view.didPressLinkButton = {
            insertLinkActive = true
        }

        view.didPressCancelButton = {
            viewModel.cancelImageUpload()
        }

        view.didPressImageButton = {
            // Insert Image
//            syntaxView.resignFirstResponder()
//            composeNavigator.openImageInsertion(sourceView: keyboardInputViewController?.view ?? view, imageInsertion: { [weak self] image in
//                self?.viewModel.insertImage(image: image)
//            }, imageUpload: { [weak self] image in
//                self?.viewModel.upload(image: image)
//            })
        }

        return view
    }

    var insertLinkView: InsertLinkView {
        InsertLinkView { title, url in
            insertLinkActive = false

            guard let url = url else { return }

            viewModel.insertLink(url: url, title: title)
        }
    }
}

private struct ReplyView: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading) {
            ItemView(item: item)
            Text("COMPOSEVIEWCONTROLLER_TABLEVIEW_HEADER_TITLE")
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
            ComposeView(viewModel: shareURLViewModel)
            ComposeView(viewModel: replyViewModel)
            ComposeView(viewModel: imageViewModel)
        }
    }
}
#endif
