//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import SwiftSoup

#if os(iOS)
import UIKit
public typealias XImage = UIImage
#elseif os(OSX)
public typealias XImage = NSImage
#endif

public final class HTMLContent: Codable {
    private let rawHTMLString: String
    private let rawHTMLStringWithoutImages: String

    public let imageLinks: [URL]
    public let imageDescriptions: [String]
    public let videoLinks: [URL]

    init(rawHTMLString: String) {
        let document = try? SwiftSoup.parse(rawHTMLString)

        self.rawHTMLString = rawHTMLString
        self.rawHTMLStringWithoutImages = rawHTMLString.withoutImages(from: document)

        self.imageLinks = rawHTMLString.imagesLinks(from: document).compactMap(URL.init)
        self.videoLinks = rawHTMLString.videoLinks(from: document).compactMap(URL.init)
        self.imageDescriptions = rawHTMLString.imageDescriptions(from: document)
    }

    public func attributedStringWithoutImages() -> NSAttributedString? {
        return rawHTMLStringWithoutImages.htmlToAttributedString()
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
        return rawHTMLString.htmlToAttributedString()
    }
}

private extension String {
    #if os(iOS)
    func htmlToAttributedString() -> NSAttributedString? {
        guard let document = try? SwiftSoup.parse(trimEmptyLines),
            let body = document.body(),
            let bodyString = try? body.text() else { return nil }

        let string = NSMutableAttributedString(string: bodyString)
        let paragraphStyle = NSMutableParagraphStyle()
        let nsString = bodyString as NSString
        paragraphStyle.lineSpacing = 1.2
        let mutableAttributedString = NSMutableAttributedString(string: string.string.trimEmptyLines, attributes: [
                .font: Font().body,
                .foregroundColor: Color.textColor,
                .paragraphStyle: paragraphStyle
        ])

        let linkValues = try? body.select("a[href]").array()

        for linkValue in (linkValues ?? []) {
            guard let content = try? linkValue.text(),
                let linkURLString = try? linkValue.attr("href"),
                let url = URL(string: linkURLString) else { continue }
            let range = nsString.range(of: content)
            mutableAttributedString.save_addAttributes([
                .foregroundColor: Color.main,
                NSAttributedString.Key(rawValue: "IcroLinkAttribute"): url
            ], range: range)

        }

        let boldValues = try? body.select("strong").array()

        for boldValue in (boldValues ?? []) {
            guard let content = try? boldValue.text() else { continue }
            let range = nsString.range(of: content)
            mutableAttributedString.save_addAttributes([
                NSAttributedString.Key.font: Font().boldBody
            ], range: range)
        }

        let italicValues = try? body.select("em").array()

        for italicValue in (italicValues ?? []) {
            guard let content = try? italicValue.text() else { continue }
            let range = nsString.range(of: content)
            mutableAttributedString.save_addAttributes([
                NSAttributedString.Key.font: Font().italicBody
            ], range: range)
        }

        return mutableAttributedString

    }
    #elseif os(OSX)
    func htmlToAttributedString() -> NSAttributedString? {
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

    func htmlToString() -> String {
        return htmlToAttributedString()?.string ?? ""
    }

    var trimEmptyLines: String {
        return self.trimmingCharacters(in: CharacterSet(["\n"]))
    }
}

private extension NSMutableAttributedString {
    func save_addAttributes(_ attributes: [NSAttributedString.Key: Any], range: NSRange) {
        guard range.location + range.length <= self.length else { return }
        addAttributes(attributes, range: range)
    }
}

private extension String {
    static let inlineMiniImageClasses = ["mini_thumbnail", "wp-smiley"]

    func videoLinks(from document: Document?) -> [String] {
        guard let document = document,
            let srcs = try? document.select("video[src]") else { return [] }

        let srcsStringArray: [String] = srcs.array().compactMap { try? $0.attr("src").description }
        return srcsStringArray
    }

    func imagesLinks(from document: Document?) -> [String] {
        guard let document = document,
            let srcs = try? document.select("img[src]") else { return [] }

        return srcs.array().compactMap {
            if let className = try? $0.className(),
                String.inlineMiniImageClasses.contains(className) {
                return nil
            }

            return try? $0.attr("src").description
        }
    }

    func imageDescriptions(from document: Document?) -> [String] {
        guard let document = document,
            let srcs = try? document.select("img[src]") else { return [] }

        return srcs.array().compactMap {
            if let className = try? $0.className(),
                String.inlineMiniImageClasses.contains(className) {
                return nil
            }

            return try? $0.attr("alt").description
        }
    }

    func withoutImages(from document: Document?) -> String {
        guard let document = document,
            let srcs = try? document.select("img[src]") else { return self }

        var mutableSelf = self

        for image in srcs.array() {
            if let className = try? image.className(),
                String.inlineMiniImageClasses.contains(className) {
                continue
            }

            let iamgeHTML = try? image.html()
            mutableSelf = mutableSelf.replacingOccurrences(of: iamgeHTML ?? "", with: "")
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
