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

    @State private var isFollowEnabled = true

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                KFImage(avatarURL)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .onTapGesture {
                        avatarPressed?()
                    }
                VStack(alignment: .leading, spacing: 2.0) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(realname)
                            .font(.title3)
                            .bold()
                        Text(username)
                            .font(.callout)
                        Spacer()
                    }
                    Text(aboutText)
                        .fontWeight(.medium)
                    Button(authorURL) {
                        profilePressed?()
                    }
                }
            }
            HStack {
                if !isOwnProfile {
                    Button(action: {
                        isFollowEnabled = false
                        followPressed?()
                    }, label: {
                        HStack {
                            Spacer()
                            followButtonText
                            Spacer()
                        }
                    }).disabled(isFollowEnabled == false)
                    .tint(Color(uiColor: Style.Color.buttonColor))
                    .buttonStyle(.borderedProminent)
                }
                Button(action: {
                    followingPressed?()
                }, label: {
                    HStack {
                        Spacer()
                        followingButtonText
                        Spacer()
                    }
                })
                .tint(Color(uiColor: Style.Color.buttonColor))
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(uiColor: Style.Color.accentLight))
        .disabled(disabledAllInteractions)
    }

    private var followButtonText: Text {
        Text(isFollowing ?
             "PROFILEVIEWCONFIGURATOR_UNFOLLOWBUTTON_TITLE" :
                "PROFILEVIEWCONFIGURATOR_FOLLOWBUTTON_TITLE")
            .fontWeight(.medium)
            .foregroundColor(Color(uiColor: Style.Color.main))
    }

    private var followingButtonText: Text {
        let title = String(
            format: NSLocalizedString("PROFILEVIEWCONFIGURATOR_FOLLOWINGBUTTON_TITLE", comment: ""), followingCount
        )

        return Text(title)
            .fontWeight(.medium)
            .foregroundColor(Color(uiColor: Style.Color.main))
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
