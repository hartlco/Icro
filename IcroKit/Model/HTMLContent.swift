//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Kanna

#if os(iOS)
import DTCoreText
#endif

#if os(iOS)
import UIKit
public typealias XImage = UIImage
#elseif os(OSX)
public typealias XImage = NSImage
#endif

public extension Notification.Name {
    static let asyncInlineImageFinishedLoading = Notification.Name(rawValue: "asyncInlineImageFinishedLoading")
}

public final class HTMLContent: Codable {
    private let rawHTMLString: String
    private let itemID: String

    public let imageLinks: [URL]
    public let videoLinks: [URL]

    init(rawHTMLString: String, itemID: String) {
        self.rawHTMLString = rawHTMLString
        self.itemID = itemID

        let htmlDocument = try? HTML(html: rawHTMLString, encoding: .utf8)

        self.imageLinks = rawHTMLString.imagesLinks(from: htmlDocument).compactMap(URL.init)
        self.videoLinks = rawHTMLString.videoLinks(from: htmlDocument).compactMap(URL.init)
    }

    public func imageDescs() -> [String] {
        return rawHTMLString.imagesDescs()
    }

    public func attributedStringWithoutImages() -> NSAttributedString? {
        return rawHTMLString.withoutImages().htmlToAttributedString(for: itemID)
    }

    public static func textLinks(for attributedString: NSAttributedString?) -> [(text: String, url: URL)] {
        guard let text = attributedString else {
            return []
        }
        var links = [(text: String, url: URL)]()
        text.enumerateAttribute(NSAttributedString.Key(rawValue: "IcroLinkAttribute"), in: NSRange(0..<text.length)) { value, range, _ in
            let linkText = text.attributedSubstring(from: range)
            if let linkUrl = value as? URL {
                links.append((text: linkText.string, url: linkUrl))
            }
        }
        return links
    }

    private func attirbutedString() -> NSAttributedString? {
        return rawHTMLString.htmlToAttributedString(for: itemID)
    }
}

private extension String {
    #if os(iOS)
    func htmlToAttributedString(for itemID: String) -> NSAttributedString? {
        let data = Data(trimEmptyLines.utf8)
        guard let string = NSMutableAttributedString(htmlData: data, options: nil, documentAttributes: nil) else { return nil }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.2
        let mutableAttributedString = NSMutableAttributedString(string: string.string.trimEmptyLines, attributes: [
                .font: Font().body,
                .foregroundColor: Color.textColor,
                .paragraphStyle: paragraphStyle
            ])

        string.enumerateAttributes(in: NSRange(location: 0, length: string.length), options: []) { (attributes, rane, _) in
            let links = attributes.filter({ key, _ in
                return key == .link
            })

            links.forEach({ _, value in
                mutableAttributedString.save_addAttributes(
                    [
                        .foregroundColor: Color.main,
                        NSAttributedString.Key(rawValue: "IcroLinkAttribute"): value
                    ], range: rane)
                return
            })

            for (_, value) in attributes {
                #if os(iOS)
                if let image = value as? DTImageTextAttachment,
                    let textAttachment = textAttachment(for: image, itemID: itemID) {
                    mutableAttributedString.save_addAttributes([
                        .attachment: textAttachment
                        ], range: rane)
                }
                #endif

                if let font = value as? XFont {
                    if font.isBold {
                        mutableAttributedString.save_addAttributes([.font: Font().boldBody], range: rane)
                    }

                    if font.isItalic {
                        mutableAttributedString.save_addAttributes([.font: Font().italicBody], range: rane)
                    }
                }
            }
        }

        return mutableAttributedString

    }
    #elseif os(OSX)
    func htmlToAttributedString(for itemID: String) -> NSAttributedString? {
        let htmlData = NSString(string: self as NSString).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
            NSAttributedString.DocumentType.html]
        guard let string = try? NSMutableAttributedString(data: htmlData ?? Data(),
                                                              options: options,
                                                              documentAttributes: nil) else {
                                                                return nil
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.1
        let mutableAttributedString = NSMutableAttributedString(string: string.string.trimEmptyLines, attributes: [
            .font: Font().body,
            .foregroundColor: NSColor.textColor,
            .paragraphStyle: paragraphStyle
            ])

        string.enumerateAttributes(in: NSRange(location: 0, length: string.length), options: []) { (attributes, rane, _) in
            let links = attributes.filter({ key, _ in
                return key == .link
            })

            links.forEach({ key, value in
                mutableAttributedString.save_addAttributes(
                    [
                        .foregroundColor: Color.main,
                        key: value
                    ], range: rane)
                return
            })

            for (_, value) in attributes {
                if let font = value as? XFont {
                    if font.isBold {
                        mutableAttributedString.save_addAttributes([.font: Font().boldBody], range: rane)
                    }

                    if font.isItalic {
                        mutableAttributedString.save_addAttributes([.font: Font().italicBody], range: rane)
                    }
                }
            }
        }

        return mutableAttributedString
    }
    #endif

    func htmlToString(for itemID: String) -> String {
        return htmlToAttributedString(for: itemID)?.string ?? ""
    }

    var trimEmptyLines: String {
        return self.trimmingCharacters(in: CharacterSet(["\n"]))
    }

    #if os(iOS)
    private func textAttachment(for textImage: DTImageTextAttachment, itemID: String) -> NSTextAttachment? {
        guard let urlString = textImage.attributes["src"] as? String,
            let url = URL(string: urlString),
            let classString = textImage.attributes["class"] as? String,
            String.inlineMiniImageClasses.contains(classString) else { return nil }

        let font = XFont.systemFont(ofSize: 16)
        let textAttachment = NSTextAttachment()

        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            let image = XImage(data: data)
            DispatchQueue.main.async {
                textAttachment.image = image
                NotificationCenter.default.post(name: .asyncInlineImageFinishedLoading, object: nil, userInfo: ["id": itemID])
            }
        }.resume()

        let mid = font.descender + font.capHeight
        let width: CGFloat = 18
        textAttachment.bounds = CGRect(x: 0, y: font.descender - width / 2 + mid + 2, width: width, height: width).integral
        return textAttachment
    }
    #endif
}

private extension NSMutableAttributedString {
    func save_addAttributes(_ attributes: [NSAttributedString.Key: Any], range: NSRange) {
        guard range.location + range.length <= self.length else { return }
        addAttributes(attributes, range: range)
    }
}

private extension String {
    static let inlineMiniImageClasses = ["mini_thumbnail", "wp-smiley"]

    func matchesIn(string: NSString!, atRangeIndex: Int!) -> [String] {
        guard let expression = try? NSRegularExpression(pattern: self, options: .caseInsensitive) else {
            return [] }

        // swiftlint:disable legacy_constructor
        let matches = expression.matches(in: string as String, options: .withoutAnchoringBounds, range: NSMakeRange(0, string.length))

        return matches.compactMap({
            return string.substring(with: $0.range(at: 1))
        })
    }

    func videoLinks(from document: HTMLDocument?) -> [String] {
        guard let document = document else { return [] }

        return document.xpath("//video | //src").compactMap {
            if let htmlClass = $0["class"], String.inlineMiniImageClasses.contains(htmlClass) {
                return nil
            }
            return $0["src"]
        }
    }

    func imagesLinks(from document: HTMLDocument?) -> [String] {
        guard let document = document else { return [] }

        return document.xpath("//img | //src").compactMap {
            if let htmlClass = $0["class"], String.inlineMiniImageClasses.contains(htmlClass) {
                return nil
            }
            return $0["src"]
        }
    }

    func imagesDescs() -> [String] {
        guard let doc = try? HTML(html: self, encoding: .utf8) else { return [] }

        return doc.xpath("//img | //alt").compactMap {
            return $0["alt"]
        }
    }

    func withoutImages() -> String {
        guard let doc = try? HTML(html: self, encoding: .utf8) else { return self }
        var mutableSelf = self

        for image in doc.xpath("//img | //src") {
            if let htmlClass = image["class"], String.inlineMiniImageClasses.contains(htmlClass) {
                continue
            }
            mutableSelf = mutableSelf.replacingOccurrences(of: image.toHTML ?? "", with: "")
        }

        return mutableSelf
    }
}

private extension XFont {
    var isBold: Bool {
        #if os(iOS)
        return fontDescriptor.symbolicTraits.contains(.traitBold)
        #elseif os(OSX)
        return false
        #endif
    }

    var isItalic: Bool {
        #if os(iOS)
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
        #elseif os(OSX)
        return false
        #endif
    }
}
