import Foundation

public struct StylePreference: Codable {
    public init(useMediumContent: Bool) {
        self.useMediumContent = useMediumContent
    }

    public let useMediumContent: Bool
}
