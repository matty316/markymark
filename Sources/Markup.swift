//
//  Markup.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Foundation

public struct Markup {
    public let elements: [Element]
    public let frontMatter: [String: String]
    public func html() throws -> String {
        try elements
            .filter { try !$0.html().isEmpty }
            .map { try $0.html() }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func min() throws -> String {
        try elements
            .filter { try !$0.html().isEmpty }
            .map { try $0.html() }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public protocol Element {
    func html() throws -> String
}

public enum LineType: String {
    case h1, h2, h3, h4, h5, h6, p, unorderedListItem, orderedListItem, blank, hr
}

public struct Content {
    let string: String
    func html() throws -> String {
        try Emitter.emitHtml(self)
    }
}

public struct Line: Element {
    let lineType: LineType
    let content: Content
    
    public func html() throws -> String {
        switch lineType {
        case .h1, .h2, .h3, .h4, .h5, .h6, .p:
            "<\(lineType.rawValue)>\(try content.html())</\(lineType.rawValue)>"
        case .hr:
            "<\(lineType.rawValue)>"
        default: ""
        }
    }
}

public struct List: Element {
    public let lines: [Line]
    public let ordered: Bool
    public func html() throws -> String {
        """
<\(ordered ? "ol" : "ul")>
\(try lines.map { "<li>\(try $0.content.html())</li>" }.joined(separator: "\n") )
</\(ordered ? "ol" : "ul")>
"""
    }
}

public struct BlockQuote: Element {
    public let lines: [Line]
    public func html() throws -> String {
        """
<blockquote>
\(try lines.map { try $0.html() }.joined(separator: "\n"))
</blockquote>
"""
    }
}

public struct CodeBlock: Element {
    public let text: String
    public func html() throws -> String {
        """
<pre><code>
\(text)
</code></pre>
"""
    }
}
