//
//  Created by Martin Hartl on 27.12.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Sourceful

public class IcroLexer: SourceCodeRegexLexer {
    public func generators(source: String) -> [TokenGenerator] {
        var generators = [TokenGenerator?]()
        // Bold
        generators.append(regexGenerator("(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)\\2(?=\\S)(.*?\\S)\\2\\2(?!\\2)(?=[\\W_]|$)",
                                         tokenType: .string))

        // Italic
        generators.append(regexGenerator("(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)(?=\\S)((?:(?!\\2).)*?\\S)\\2(?!\\2)(?=[\\W_]|$)",
                                         tokenType: .identifier))

        // Code
        generators.append(regexGenerator("(`[^`]{1,}`)",
                                         tokenType: .comment))

        // URL
        generators.append(regexGenerator("\\[([^\\]]+)\\]\\(([^\\)\"\\s]+)(?:\\s+\"(.*)\")?\\)",
                                         tokenType: .keyword))

        // Image
        generators.append(regexGenerator("\\!\\[([^\\]]+)\\]\\(([^\\)\"\\s]+)(?:\\s+\"(.*)\")?\\)",
                                         tokenType: .keyword))

        return generators.compactMap({ $0 })
    }
}
