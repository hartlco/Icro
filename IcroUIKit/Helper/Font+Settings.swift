import Style
import Settings

public extension Style.Font {
    init() {
        self.init(stylePreference: .init(useMediumContent: Settings.UserSettings.shared.useMediumContentFont))
    }
}
