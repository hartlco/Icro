//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import Kanna
import DTCoreText
import SDWebImage

final class HTMLContent: Codable {
    private let rawHTMLString: String
    private let itemID: String

    init(rawHTMLString: String, itemID: String) {
        self.rawHTMLString = rawHTMLString
        self.itemID = itemID
    }

    func imageLinks() -> [URL] {
        return rawHTMLString.imagesLinks().compactMap(URL.init)
    }

    func attributedStringWithoutImages() -> NSAttributedString? {
        return rawHTMLString.withoutImages().htmlToAttributedString(for: itemID)
    }

    static func textLinks(for attributedString: NSAttributedString?) -> [(text: String, url: URL)] {
        guard let text = attributedString else {
            return []
        }
        var links = [(text: String, url: URL)]()
        text.enumerateAttribute(NSAttributedStringKey(rawValue: "IcroLinkAttribute"), in: NSRange(0..<text.length)) { value, range, _ in
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
    func htmlToAttributedString(for itemID: String) -> NSAttributedString? {
        let data = Data(trimEmptyLines.utf8)
        guard let string = NSMutableAttributedString(htmlData: data, options: nil, documentAttributes: nil) else { return nil }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.2
        let mutableAttributedString = NSMutableAttributedString(string: string.string.trimEmptyLines, attributes: [
                .font: Font().body,
                .paragraphStyle: paragraphStyle
            ])

        string.enumerateAttributes(in: NSRange(location: 0, length: string.length), options: []) { (attributes, rane, _) in
            let links = attributes.filter({ key, _ in
                return key == .link
            })

            links.forEach({ _, value in
                mutableAttributedString.save_addAttributes(
                    [
                        NSAttributedStringKey.foregroundColor: Color.main,
                        NSAttributedStringKey(rawValue: "IcroLinkAttribute"): value
                    ], range: rane)
                return
            })

            for (_, value) in attributes {
                if let image = value as? DTImageTextAttachment,
                    let textAttachment = textAttachment(for: image, itemID: itemID) {
                    mutableAttributedString.save_addAttributes([
                        NSAttributedStringKey.attachment: textAttachment
                        ], range: rane)
                }

                if let font = value as? UIFont {
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
    func htmlToString(for itemID: String) -> String {
        return htmlToAttributedString(for: itemID)?.string ?? ""
    }

    var trimEmptyLines: String {
        return self.trimmingCharacters(in: CharacterSet(["\n"]))
    }

    private func textAttachment(for textImage: DTImageTextAttachment, itemID: String) -> NSTextAttachment? {
        guard let urlString = textImage.attributes["src"] as? String,
            let url = URL(string: urlString),
            let classString = textImage.attributes["class"] as? String,
            String.inlineMiniImageClasses.contains(classString) else { return nil }

        let font = UIFont.systemFont(ofSize: 16)
        let textAttachment = NSTextAttachment()

        SDWebImageManager.shared().loadImage(with: url, options: [], progress: nil) { (image, _, _, _, _, _) in
            DispatchQueue.main.async {
                textAttachment.image = image
                NotificationCenter.default.post(name: .asyncInlineImageFinishedLoading, object: nil, userInfo: ["id": itemID])
            }
        }

        let mid = font.descender + font.capHeight
        let width: CGFloat = 18
        textAttachment.bounds = CGRect(x: 0, y: font.descender - width / 2 + mid + 2, width: width, height: width).integral
        return textAttachment
    }
}

private extension NSMutableAttributedString {
    func save_addAttributes(_ attributes: [NSAttributedStringKey: Any], range: NSRange) {
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

    func htmlImgSources() -> [String] {
        return "src=\\\"([^\"]+)\"".matchesIn(string: self as NSString, atRangeIndex: 1)
    }

    func imagesLinks() -> [String] {
        guard let doc = try? HTML(html: self, encoding: .utf8) else { return [] }

        return doc.xpath("//img | //src").compactMap {
            if let htmlClass = $0["class"], String.inlineMiniImageClasses.contains(htmlClass) {
                return nil
            }
            return $0["src"]
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

private extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}
