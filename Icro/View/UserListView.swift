//
//  UserListView.swift
//  Icro
//
//  Created by martin on 30.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import Kingfisher

struct UserListView: SwiftUI.View {
    @ObservedObject var viewModel: UserListViewModel
    let itemNavigator: ItemNavigator

    var body: some SwiftUI.View {
        Group {
            if viewModel.isLoading {
                LoadingSkeletonView(kind: .people)
            } else {
                List(viewModel.users, id: \.self) { author in
                    Button {
                        itemNavigator.open(author: author)
                    } label: {
                        FollowingUserRow(avatarURL: author.avatar,
                                         name: author.name,
                                         username: author.username)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("USERLISTVIEWCONTROLLER_TITLE")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

private struct FollowingUserRow: View {
    let avatarURL: URL
    let name: String
    let username: String?

    var body: some View {
        HStack(spacing: 12) {
            KFImage(avatarURL)
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let username, !username.isEmpty {
                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(minHeight: 54)
        .contentShape(Rectangle())
    }
}
