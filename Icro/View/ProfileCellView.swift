//
//  ProfileCellView.swift
//  Icro
//
//  Created by martinhartl on 04.12.21.
//  Copyright © 2021 Martin Hartl. All rights reserved.
//

import SwiftUI
import Kingfisher
import Style

struct ProfileCellView: View {
    let avatarURL: URL
    let realname: String
    let username: String
    let aboutText: String
    let authorURL: String
    let isOwnProfile: Bool
    let isFollowing: Bool
    let followingCount: Int
    let disabledAllInteractions: Bool

    var profilePressed: (() -> Void)?
    var followPressed: (() -> Void)?
    var followingPressed: (() -> Void)?
    var avatarPressed: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProfileIdentity(avatarURL: avatarURL,
                            realname: realname,
                            username: username,
                            avatarPressed: avatarPressed)

            ProfileDetails(aboutText: aboutText,
                           authorURL: authorURL,
                           profilePressed: profilePressed)

            ProfileActions(isOwnProfile: isOwnProfile,
                           isFollowing: isFollowing,
                           followingCount: followingCount,
                           followPressed: followPressed,
                           followingPressed: followingPressed)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .disabled(disabledAllInteractions)
    }
}

private struct ProfileIdentity: View {
    let avatarURL: URL
    let realname: String
    let username: String
    let avatarPressed: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Button {
                avatarPressed?()
            } label: {
                KFImage(avatarURL)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(realname)

            VStack(alignment: .leading, spacing: 3) {
                Text(realname)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(username)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ProfileDetails: View {
    let aboutText: String
    let authorURL: String
    let profilePressed: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            if !aboutText.isEmpty {
                Text(aboutText)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !authorURL.isEmpty {
                Button {
                    profilePressed?()
                } label: {
                    Label {
                        Text(authorURL)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    } icon: {
                        Image(systemName: "link")
                    }
                    .font(.subheadline)
                    .foregroundStyle(Style.Color.main.swiftUIColor)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ProfileActions: View {
    let isOwnProfile: Bool
    let isFollowing: Bool
    let followingCount: Int
    let followPressed: (() -> Void)?
    let followingPressed: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            if !isOwnProfile {
                if isFollowing {
                    Button(action: { followPressed?() }) {
                        Label("PROFILEVIEWCONFIGURATOR_UNFOLLOWBUTTON_TITLE", systemImage: "person.crop.circle.badge.checkmark")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.tint(Style.Color.main.swiftUIColor).interactive(), in: Capsule())
                } else {
                    Button(action: { followPressed?() }) {
                        Label("PROFILEVIEWCONFIGURATOR_FOLLOWBUTTON_TITLE", systemImage: "person.badge.plus")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.tint(Style.Color.main.swiftUIColor).interactive(), in: Capsule())
                }
            }

            Button(action: { followingPressed?() }) {
                Label(followingTitle, systemImage: "person.2")
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(Style.Color.main.swiftUIColor).interactive(), in: Capsule())
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.primary)
    }

    private var followingTitle: String {
        let format = NSLocalizedString("PROFILEVIEWCONFIGURATOR_FOLLOWINGBUTTON_TITLE", comment: "Following count")
        return String.localizedStringWithFormat(format, followingCount)
    }
}

struct ProfileCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCellView(
            avatarURL: .init(string: "http://micro.blog/photos/96/https://micro.blog/hartlco/avatar.jpg")!,
            realname: "Martin Hartl",
            username: "@hartlco",
            aboutText: "iOS Developer from Berlin, Germany. Try out Icro",
            authorURL: "https://hartl.co",
            isOwnProfile: false,
            isFollowing: false,
            followingCount: 120,
            disabledAllInteractions: false
        )
    }
}
