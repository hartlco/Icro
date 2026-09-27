import SwiftUI

enum LoadingSkeletonKind {
    case feed(profile: Bool)
    case people
}

struct LoadingSkeletonView: View {
    let kind: LoadingSkeletonKind

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shimmerPosition = false

    var body: some View {
        VStack(spacing: 0) {
            switch kind {
            case .feed(let profile):
                if profile {
                    SkeletonProfileHeader(shimmerPosition: shimmerPosition)
                }
                ForEach(0..<(profile ? 2 : 4), id: \.self) { index in
                    SkeletonPostRow(index: index, shimmerPosition: shimmerPosition)
                }
            case .people:
                ForEach(0..<8, id: \.self) { _ in
                    SkeletonPersonRow(shimmerPosition: shimmerPosition)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .clipped()
        .background(Color(uiColor: .systemBackground))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("UIVIEWCONTROLLERLOADING_LOADING_TEXT"))
        .allowsHitTesting(false)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 1.35).repeatForever(autoreverses: false)) {
                shimmerPosition = true
            }
        }
    }
}

private struct SkeletonProfileHeader: View {
    let shimmerPosition: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                SkeletonBlock(width: 72, height: 72, cornerRadius: 36, shimmerPosition: shimmerPosition)
                VStack(alignment: .leading, spacing: 9) {
                    SkeletonBlock(width: 150, height: 17, shimmerPosition: shimmerPosition)
                    SkeletonBlock(width: 104, height: 13, shimmerPosition: shimmerPosition)
                }
                .padding(.top, 8)
                Spacer(minLength: 0)
            }
            SkeletonBlock(height: 13, shimmerPosition: shimmerPosition)
            SkeletonBlock(width: 230, height: 13, shimmerPosition: shimmerPosition)
            HStack(spacing: 12) {
                SkeletonBlock(width: 100, height: 34, cornerRadius: 17, shimmerPosition: shimmerPosition)
                SkeletonBlock(width: 85, height: 34, cornerRadius: 17, shimmerPosition: shimmerPosition)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { Rectangle().fill(.quaternary).frame(height: 0.5) }
    }
}

private struct SkeletonPostRow: View {
    let index: Int
    let shimmerPosition: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SkeletonBlock(width: 40, height: 40, cornerRadius: 20, shimmerPosition: shimmerPosition)
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 7) {
                    SkeletonBlock(width: 112, height: 15, shimmerPosition: shimmerPosition)
                    SkeletonBlock(width: 70, height: 13, shimmerPosition: shimmerPosition)
                }
                SkeletonBlock(height: 14, shimmerPosition: shimmerPosition)
                SkeletonBlock(width: index.isMultiple(of: 2) ? 210 : 165,
                              height: 14,
                              shimmerPosition: shimmerPosition)
                if index == 0 {
                    SkeletonBlock(height: 158, cornerRadius: 14, shimmerPosition: shimmerPosition)
                }
                HStack {
                    Spacer()
                    SkeletonBlock(width: 34, height: 22, cornerRadius: 11, shimmerPosition: shimmerPosition)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { Rectangle().fill(.quaternary).frame(height: 0.5) }
    }
}

private struct SkeletonPersonRow: View {
    let shimmerPosition: Bool

    var body: some View {
        HStack(spacing: 12) {
            SkeletonBlock(width: 48, height: 48, cornerRadius: 24, shimmerPosition: shimmerPosition)
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock(width: 155, height: 15, shimmerPosition: shimmerPosition)
                SkeletonBlock(width: 105, height: 13, shimmerPosition: shimmerPosition)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct SkeletonBlock: View {
    var width: CGFloat? = nil
    let height: CGFloat
    var cornerRadius: CGFloat = 5
    let shimmerPosition: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(uiColor: .tertiarySystemFill))
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(colors: [.clear, Color(uiColor: .secondarySystemFill), .clear],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                        .frame(width: geometry.size.width * 0.65)
                        .offset(x: shimmerPosition ? geometry.size.width * 1.4 : -geometry.size.width)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .frame(width: width, height: height)
    }
}
