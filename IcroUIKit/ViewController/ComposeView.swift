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
import PhotosUI
import UIKit

private final class ComposeEditorReference {
    weak var textView: UITextView?
}

struct ComposeView: View {
    @ObservedObject var viewModel: ComposeViewModel

    @Environment(\.dismiss) var dismiss

    @State var insertLinkActive = false
    @State var insertImageURLActive = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var didFocusEditor = false
    @State private var showingPostError = false
    @State private var postErrorText = ""
    @State private var editorSelection = NSRange(location: 0, length: 0)
    @State private var editorReference = ComposeEditorReference()

    private static let mentionPattern = try! NSRegularExpression(
        pattern: "(?<![\\p{L}\\p{N}_@/])@[\\p{L}\\p{N}_.-]+"
    )
    private static let editorHighlightRules = [HighlightRule].markdown + [
        HighlightRule(pattern: mentionPattern,
                      formattingRule: TextFormattingRule(key: .foregroundColor,
                                                         value: Style.Color.accent))
    ]

    var didClose: (() -> Void)?

    init(viewModel: ComposeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if let item = viewModel.replyItem {
                    ReplyView(item: item)
                } else {
                    PostingOptionsView(viewModel: viewModel)
                        .padding(.top, 4)
                }
                HighlightedTextEditor(
                    text: $viewModel.text,
                    highlightRules: Self.editorHighlightRules
                )
                .introspect { editor in
                    editorReference.textView = editor.textView
                    editor.textView.tintColor = Style.Color.accent
                    guard viewModel.showKeyboardOnAppear, !didFocusEditor else { return }
                    DispatchQueue.main.async {
                        guard !didFocusEditor else { return }
                        didFocusEditor = true
                        editor.textView.becomeFirstResponder()
                    }
                }
                .onSelectionChange { editorSelection = $0 }
                .onTextChange { _ in
                    DispatchQueue.main.async {
                        if let selection = editorReference.textView?.selectedRange {
                            editorSelection = selection
                        }
                    }
                }
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
                        .background(Style.Color.accentLight.swiftUIColor)
                    }
                    .padding()
                    .background(Style.Color.accentSuperLight.swiftUIColor)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 8) {
                    if let mention = activeMention {
                        MentionSuggestionsView(
                            authors: viewModel.mentionSuggestions(matching: mention.searchText),
                            isLoading: viewModel.mentionsLoading,
                            onSelect: { completeMention($0, mention: mention) }
                        )
                    }
                    keyboardInputView
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            .navigationDestination(isPresented: $insertLinkActive) {
                insertLinkView
            }
            .navigationDestination(isPresented: $insertImageURLActive) {
                insertImageLinkView
            }
            .photosPicker(isPresented: $viewModel.imagePickerActive,
                          selection: $selectedPhoto,
                          matching: .images)
            .onChange(of: selectedPhoto) { _, photo in
                Task {
                    let data = try? await photo?.loadTransferable(type: Data.self)
                    await MainActor.run {
                        viewModel.pickedImage = data
                        selectedPhoto = nil
                    }
                }
            }
            .task { await viewModel.loadPublishingOptions() }
            .task { await viewModel.loadFollowingCandidates() }
            .task { await viewModel.loadReplyThreadCandidates() }
            .alert("COMPOSE_POST_ERROR_TITLE", isPresented: $showingPostError) {
                Button("COMPOSE_POST_ERROR_OK", role: .cancel) { }
            } message: {
                Text(postErrorText)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("COMPOSEVIEWCONTROLLER_CANCELBUTTON_TITLE", comment: "")) {
                        dismissView()
                    }
                }
                ToolbarItem(placement: .topBarPinnedTrailing) {
                    HStack(spacing: 8) {
                        if viewModel.uploading {
                            ProgressView()
                        }
                        Button(action: submitPost) {
                            if viewModel.isDraft && !viewModel.isReply {
                                Text("COMPOSE_SAVE_DRAFT")
                            } else {
                                Text("KEYBOARDINPUTVIEW_POSTBUTTON_TITLE")
                            }
                        }
                        .disabled(viewModel.uploading || (viewModel.text.isEmpty && viewModel.images.isEmpty))
                    }
                }
            }
            // TODO: Add Drag/Drop interaction
            .navigationTitle(NSLocalizedString("COMPOSEVIEWCONTROLLER_TITLE", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var keyboardInputView: ComposeKeyboardInputView {
        var view = ComposeKeyboardInputView(viewModel: viewModel.composeKeyboardInputViewModel,
                                            isDraft: viewModel.isDraft && !viewModel.isReply)
        view.didPressPostButton = submitPost

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

    private func submitPost() {
        Task {
            do {
                try await viewModel.post()
                dismissView()
            } catch {
                postErrorText = error.text
                showingPostError = true
            }
        }
    }

    private var activeMention: MentionQuery? {
        MentionQuery.active(in: viewModel.text, selection: editorSelection)
    }

    private func completeMention(_ author: Author, mention: MentionQuery) {
        guard let username = author.username else { return }
        let completion = mention.completing(with: username, in: viewModel.text)
        editorSelection = NSRange(location: completion.cursor, length: 0)
        viewModel.text = completion.text
        DispatchQueue.main.async {
            editorReference.textView?.becomeFirstResponder()
            editorReference.textView?.selectedRange = NSRange(location: completion.cursor, length: 0)
        }
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

private struct MentionSuggestionsView: View {
    let authors: [Author]
    let isLoading: Bool
    let onSelect: (Author) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("COMPOSE_MENTIONS_TITLE")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            if authors.isEmpty {
                HStack(spacing: 10) {
                    if isLoading { ProgressView() }
                    if isLoading {
                        Text("COMPOSE_MENTIONS_LOADING")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("COMPOSE_MENTIONS_EMPTY")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(authors, id: \.username) { author in
                            Button { onSelect(author) } label: {
                                HStack(spacing: 10) {
                                    KFImage(author.avatar)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 36, height: 36)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(author.name)
                                            .font(.subheadline.weight(.semibold))
                                            .lineLimit(1)
                                        Text("@\(author.username ?? "")")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 12)
                                .frame(height: 52)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: min(CGFloat(authors.count) * 52, 208))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .glassEffect(.regular.tint(Style.Color.main.swiftUIColor), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.09), radius: 12, y: 4)
    }
}

private struct PostingOptionsView: View {
    @ObservedObject var viewModel: ComposeViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Menu {
                    Button("COMPOSE_DEFAULT_BLOG") {
                        Task { await viewModel.selectDestination(nil) }
                    }
                    ForEach(viewModel.destinations) { destination in
                        Button {
                            Task { await viewModel.selectDestination(destination) }
                        } label: {
                            if viewModel.selectedDestination == destination {
                                Label(destination.title, systemImage: "checkmark")
                            } else {
                                Text(destination.title)
                            }
                        }
                    }
                } label: {
                    Label {
                        if let destination = viewModel.selectedDestination {
                            Text(destination.title)
                        } else {
                            Text("COMPOSE_DEFAULT_BLOG")
                        }
                    } icon: {
                        Image(systemName: "globe")
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 48)
                }
                .glassEffect(.regular.tint(Style.Color.main.swiftUIColor).interactive(), in: Capsule())

                Menu {
                    ForEach(viewModel.availableCategories, id: \.self) { category in
                        Button {
                            viewModel.toggleCategory(category)
                        } label: {
                            if viewModel.selectedCategories.contains(category) {
                                Label(category, systemImage: "checkmark")
                            } else {
                                Text(category)
                            }
                        }
                    }
                } label: {
                    Label {
                        HStack(spacing: 4) {
                            Text("COMPOSE_CATEGORIES")
                            if !viewModel.selectedCategories.isEmpty {
                                Text(viewModel.selectedCategories.count, format: .number)
                            }
                        }
                    } icon: {
                        Image(systemName: "folder")
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 48)
                }
                .disabled(viewModel.availableCategories.isEmpty)
                .glassEffect(.regular.tint(Style.Color.main.swiftUIColor).interactive(), in: Capsule())

                Button {
                    viewModel.isDraft.toggle()
                } label: {
                    if viewModel.isDraft {
                        Label("COMPOSE_DRAFT_SELECTED", systemImage: "checkmark.circle.fill")
                    } else {
                        Label("COMPOSE_DRAFT_OPTION", systemImage: "doc")
                    }
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .glassEffect(.regular.tint(Style.Color.main.swiftUIColor).interactive(), in: Capsule())

                if viewModel.publishingOptionsFailed {
                    Button("COMPOSE_RETRY_OPTIONS") {
                        Task { await viewModel.loadPublishingOptions() }
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 48)
                    .glassEffect(.regular.tint(Style.Color.main.swiftUIColor).interactive(), in: Capsule())
                }
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
        .accessibilityIdentifier("postingOptions")
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
