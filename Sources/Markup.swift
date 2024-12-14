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
    public func html() -> String {
        elements
            .filter { !$0.html().isEmpty }
            .map { $0.html() }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func min() -> String {
        elements
            .filter { !$0.html().isEmpty }
            .map { $0.html() }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public protocol Element {
    func html() -> String
}

public enum LineType: String {
    case h1, h2, h3, h4, h5, h6, p, unorderedListItem, orderedListItem, blank
}

public struct Content {
    let string: String
    func html() -> String {
        Emitter.emitHtml(self)
    }
}

public struct Line: Element {
    let lineType: LineType
    let content: Content
    
    public func html() -> String {
        switch lineType {
        case .h1, .h2, .h3, .h4, .h5, .h6, .p:
            "<\(lineType.rawValue)>\(content.html())</\(lineType.rawValue)>"
        default: ""
        }
    }
}

public struct List: Element {
    public let lines: [Line]
    public let ordered: Bool
    public func html() -> String {
        """
<\(ordered ? "ol" : "ul")>
\(lines.map { "<li>\($0.content.html())</li>" }.joined(separator: "\n") )
</\(ordered ? "ol" : "ul")>
"""
    }
}
