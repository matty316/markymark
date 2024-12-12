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
            .map { $0.html() }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func min() -> String {
        elements
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

public struct Line: Element {
    let lineType: LineType
    let content: String
    
    public func html() -> String {
        switch lineType {
        case .h1, .h2, .h3, .h4, .h5, .h6, .p:
            "<\(lineType.rawValue)>\(content)</\(lineType.rawValue)>"
        default: ""
        }
    }
}

public struct List: Element {
    let lines: [Line]
    public func html() -> String {
        ""
    }
}
