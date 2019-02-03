// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let cancel = ImageAsset(name: "cancel")
  internal static let accent = ColorAsset(name: "accent")
  internal static let accentDark = ColorAsset(name: "accentDark")
  internal static let accentLight = ColorAsset(name: "accentLight")
  internal static let accentSuperLight = ColorAsset(name: "accentSuperLight")
  internal static let blackTransparent = ColorAsset(name: "blackTransparent")
  internal static let main = ColorAsset(name: "main")
  internal static let secondaryTextColor = ColorAsset(name: "secondaryTextColor")
  internal static let separatorColor = ColorAsset(name: "separatorColor")
  internal static let success = ColorAsset(name: "success")
  internal static let whiteTransparent = ColorAsset(name: "whiteTransparent")
  internal static let yellow = ColorAsset(name: "yellow")
  internal static let blackAccentLight = ColorAsset(name: "black-accentLight")
  internal static let blackAccentSuperLight = ColorAsset(name: "black-accentSuperLight")
  internal static let blackSecondaryTextColor = ColorAsset(name: "black-secondaryTextColor")
  internal static let blackSeparatorColor = ColorAsset(name: "black-separatorColor")
  internal static let blackTextColor = ColorAsset(name: "black-textColor")
  internal static let grayBackgroundColor = ColorAsset(name: "gray-backgroundColor")
  internal static let grayButtonColor = ColorAsset(name: "gray-buttonColor")
  internal static let graySecondaryTextColor = ColorAsset(name: "gray-secondaryTextColor")
  internal static let grayTextColor = ColorAsset(name: "gray-textColor")
  internal static let conversation = ImageAsset(name: "conversation")
  internal static let discover = ImageAsset(name: "discover")
  internal static let favorite = ImageAsset(name: "favorite")
  internal static let favorites = ImageAsset(name: "favorites")
  internal static let mentions = ImageAsset(name: "mentions")
  internal static let more = ImageAsset(name: "more")
  internal static let new = ImageAsset(name: "new")
  internal static let profile = ImageAsset(name: "profile")
  internal static let reply = ImageAsset(name: "reply")
  internal static let settings = ImageAsset(name: "settings")
  internal static let share = ImageAsset(name: "share")
  internal static let timeline = ImageAsset(name: "timeline")
  internal static let unfavorite = ImageAsset(name: "unfavorite")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
