import AVKit
import SwiftUI

struct MediaGalleryView: View {
    let media: [Media]
    let startIndex: Int

    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int

    init(media: [Media], startIndex: Int) {
        self.media = media
        self.startIndex = startIndex
        _selectedIndex = State(initialValue: startIndex)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedIndex) {
                ForEach(media.indices, id: \.self) { index in
                    Group {
                        if media[index].isVideo {
                            VideoMediaPage(url: media[index].url,
                                           isSelected: selectedIndex == index)
                        } else {
                            AsyncImage(url: media[index].url) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: media.count > 1 ? .automatic : .never))
            .background(Color(uiColor: .secondarySystemBackground))
            .navigationTitle("\(selectedIndex + 1) of \(media.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarPinnedTrailing) {
                    Button("Done", systemImage: "xmark") { dismiss() }
                }
            }
        }
        .tint(Color(uiColor: .label))
    }
}

private struct VideoMediaPage: View {
    let url: URL
    let isSelected: Bool

    @State private var player = AVPlayer()

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if player.currentItem == nil {
                    player.replaceCurrentItem(with: AVPlayerItem(url: url))
                }
                updatePlayback()
            }
            .onChange(of: isSelected) { _, _ in updatePlayback() }
            .onDisappear { player.pause() }
    }

    private func updatePlayback() {
        if isSelected {
            player.play()
        } else {
            player.pause()
        }
    }
}
