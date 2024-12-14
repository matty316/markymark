//
//  HTMLTests.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Testing
@testable import MarkyMark

struct HTMLTests {
    func getHTML(input: String) throws -> String {
        var s = Scanner(input: input)
        var p = Parser(tokens: try s.scan())
        let markup = try p.parse()
        return markup.html()
    }
    
    func getHTMLMin(input: String) throws -> String {
        var s = Scanner(input: input)
        var p = Parser(tokens: try s.scan())
        let markup = try p.parse()
        return markup.min()
    }
    
    @Test func testLines() throws {
        let html = try getHTML(input: """
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
        
        let exp = """
<h1>heading 1</h1>

<h2>heading 2</h2>

<h3>heading 3</h3>

<h4>heading 4</h4>

<h5>heading 5</h5>

<h6>heading 6</h6>

<p>####### not a heading</p>

<p>#not a heading</p>

<p>look at this paragraaaaph</p>
"""
        #expect(html == exp)
    }
    
    @Test func testLinesMin() throws {
        let html = try getHTMLMin(input: """
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
        
        let exp = "<h1>heading 1</h1><h2>heading 2</h2><h3>heading 3</h3><h4>heading 4</h4><h5>heading 5</h5><h6>heading 6</h6><p>####### not a heading</p><p>#not a heading</p><p>look at this paragraaaaph</p>"
        #expect(html == exp)
    }
    
    @Test(arguments: [
        """
- item 1
- item 2
- item 3
""","""
+ item 1
+ item 2
+ item 3
""","""
* item 1
* item 2
* item 3
""",
    ]) func testUnorderedLists(input: String) throws {
        let html = try getHTML(input: input)
        let exp = """
<ul>
\t<li>item 1</li>
\t<li>item 2</li>
\t<li>item 3</li>
</ul>
"""
        #expect(html == exp)
    }
    
    @Test(arguments: [
        """
1. item 1
2. item 2
3. item 3
""",
    ]) func testOrderedLists(input: String) throws {
        let html = try getHTML(input: input)
        let exp = """
<ol>
\t<li>item 1</li>
\t<li>item 2</li>
\t<li>item 3</li>
</ol>
"""
        #expect(html == exp)
    }
    
    @Test(arguments: zip([
        "paragraph with *emphasis*",
        "paragraph with _emphasis_",
        "paragraph with **emphasis**",
        "paragraph with __emphasis__",
        "paragraph with ***emphasis***",
        "paragraph with ___emphasis___",
    ], [
        "<p>paragraph with <em>emphasis</em></p>",
        "<p>paragraph with <em>emphasis</em></p>",
        "<p>paragraph with <strong>emphasis</strong></p>",
        "<p>paragraph with <strong>emphasis</strong></p>",
        "<p>paragraph with <em><strong>emphasis</strong></em></p>",
    ]))
    func testParagraphWithEmphasis(input: String, exp: String) throws {
        let html = try getHTML(input: input)
        #expect(html == exp)
    }
}

