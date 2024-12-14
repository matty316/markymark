//
//  ParserTests.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Testing
@testable import MarkyMark

struct ParserTests {
    func parse(input: String) throws -> Markup {
        var scanner = Scanner(input: input)
        var parser = Parser(tokens: try scanner.scan())
        return try parser.parse()
    }
    
    @Test func parseLine() throws {
        let markup = try parse(input: """
# heading 1

## heading 2

### heading 3

#### heading 4

##### heading 5

###### heading 6

####### not a heading

#not a heading

look at this paragraaaaph
""")
        
        let elements = markup.elements
        let h1 = elements[0] as! Line
        let h2 = elements[2] as! Line
        let h3 = elements[4] as! Line
        let h4 = elements[6] as! Line
        let h5 = elements[8] as! Line
        let h6 = elements[10] as! Line
        let p = elements[12] as! Line
        let p2 = elements[14] as! Line
        let p3 = elements[16] as! Line
        
        #expect(h1.lineType == .h1)
        #expect(h2.lineType == .h2)
        #expect(h3.lineType == .h3)
        #expect(h4.lineType == .h4)
        #expect(h5.lineType == .h5)
        #expect(h6.lineType == .h6)
        #expect(p.lineType == .p)
        #expect(p2.lineType == .p)
        #expect(p3.lineType == .p)
        #expect(h1.content.html() == "heading 1")
        #expect(h2.content.html() == "heading 2")
        #expect(h3.content.html() == "heading 3")
        #expect(h4.content.html() == "heading 4")
        #expect(h5.content.html() == "heading 5")
        #expect(h6.content.html() == "heading 6")
        #expect(p.content.html() == "####### not a heading")
        #expect(p2.content.html() == "#not a heading")
        #expect(p3.content.html() == "look at this paragraaaaph")
    }
    
    @Test func testFrontMatter() throws {
        let input = """
---
title: test title
date: 01-08-2025
---

# header

paragraph
"""
        let markup = try parse(input: input)
        #expect(markup.frontMatter["title"] == "test title")
        #expect(markup.frontMatter["date"] == "01-08-2025")
        #expect(markup.elements[0].html() == "<h1>header</h1>")
    }
    
    @Test func testOrderedLists() throws {
        let input = """
1. item 1
2. another item
3. last item

1 not part 2. of 1. the list 3.
"""
        
        let markup = try parse(input: input)
        let elements = markup.elements
        let list = elements[0] as! List
        let item1 = list.lines[0]
        let item2 = list.lines[1]
        let item3 = list.lines[2]
        let p = elements[2] as! Line
        #expect(list.ordered == true)
        #expect(item1.lineType == .orderedListItem)
        #expect(item2.lineType == .orderedListItem)
        #expect(item3.lineType == .orderedListItem)
        #expect(p.lineType == .p)
        #expect(item1.content.html() == "item 1")
        #expect(item2.content.html() == "another item")
        #expect(item3.content.html() == "last item")
        #expect(p.content.html() == "1 not part 2. of 1. the list 3.")
    }
    
    @Test(arguments: ["""
- item 1
- another item
- last item
""","""
* item 1
* another item
* last item
""","""
+ item 1
+ another item
+ last item
"""])
    func testUnorderedLists(input: String) throws {
        let markup = try parse(input: input)
        let elements = markup.elements
        let list = elements[0] as! List
        let item1 = list.lines[0]
        let item2 = list.lines[1]
        let item3 = list.lines[2]
        #expect(list.ordered == false)
        #expect(item1.lineType == .unorderedListItem)
        #expect(item2.lineType == .unorderedListItem)
        #expect(item3.lineType == .unorderedListItem)
        #expect(item1.content.html() == "item 1")
        #expect(item2.content.html() == "another item")
        #expect(item3.content.html() == "last item")
    }
}
