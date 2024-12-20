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
        return try markup.html()
    }
    
    func getHTMLMin(input: String) throws -> String {
        var s = Scanner(input: input)
        var p = Parser(tokens: try s.scan())
        let markup = try p.parse()
        return try markup.min()
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
<li>item 1</li>
<li>item 2</li>
<li>item 3</li>
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
<li>item 1</li>
<li>item 2</li>
<li>item 3</li>
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
    
    @Test func testBlockQuotes() throws {
        let input = """
> this is a block quote
> this is a second line of the same quote 
"""
        let html = try getHTML(input: input)
        #expect(html == """
<blockquote>
<p>this is a block quote</p>
<p>this is a second line of the same quote</p>
</blockquote>
""")
    }
    
    @Test func testCodeBlock() throws {
        let input = """
```
let string = "string"
func concat(string1: String, string2: String) {
    print(string1 + string2)
}
```
"""
        let html = try getHTML(input: input)
        let exp = """
<pre><code>
let string = "string"
func concat(string1: String, string2: String) {
    print(string1 + string2)
}
</code></pre>
"""
        #expect(html == exp)
    }
    
    @Test(arguments: ["\n---", "***", "___", "\n--------", "_________", "****************"])
    func testHR(input: String) throws {
        let html = try getHTML(input: input)
        #expect(html == "<hr>")
    }
    
    @Test(arguments: zip([
        "![alt text](img/image.jpeg)",
        "![alt text](https://google.com/image.png)"
    ], [
        ("alt text", "img/image.jpeg"),
        ("alt text", "https://google.com/image.png")
    ]))
    func testImgs(input: String, exp: (alt: String, src: String)) throws {
        let html = try getHTML(input: input)
        let expTag = "<img src=\"\(exp.src)\" alt=\"\(exp.alt)\">"
        #expect(html == expTag)
    }
    
    @Test(arguments: zip([
        "\\* this is not a list*",
        "this is not \\*empasis\\*",
        "this aint \\`no code\\`"
    ], [
        "<p><em> this is not a list</em></p>", //Ummm is this correct? kinda ambiguous. TODO: rtfm then add more tests
        "<p>this is not *empasis*</p>",
        "<p>this aint `no code`</p>"
        ]))
    func testEscaping(input: String, exp: String) throws {
        let html = try getHTML(input: input)
        #expect(html == exp)
    }
    
    @Test(arguments: zip([
        "this is a paragraph with a link to [sonic the hedgehog](https://www.sonicthehedgehog.com/)",
        "this is a line with unescaped chars [shameless plug](https://www.youtube.com/@4nem_matty)"
    ], [
        "<p>this is a paragraph with a link to <a href=\"https://www.sonicthehedgehog.com/\">sonic the hedgehog</a></p>",
        "<p>this is a line with unescaped chars <a href=\"https://www.youtube.com/@4nem_matty\">shameless plug</a></p>"
    ])) func testLinks(input: String, exp: String) throws {
        
        let html = try getHTML(input: input)
        #expect(html == exp)
    }
    
    @Test func testFullDoc() throws {
        let input = """
# This is the title

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec neque commodo, aliquam nulla et, consectetur est. Nam nec tortor ut nisl pulvinar egestas sit amet ac magna. Duis viverra malesuada viverra. Mauris condimentum sem at nibh pellentesque condimentum. Fusce ut tellus eget diam pellentesque aliquam. Cras est massa, semper in nibh sit amet, lobortis pharetra ligula. Morbi cursus fermentum felis a fringilla. Praesent orci mi, interdum et pellentesque eget, dictum in mi. Praesent sagittis diam sit amet lectus `varius`, eget iaculis eros pharetra. Donec ligula lacus, auctor in tellus quis, elementum imperdiet lorem. Suspendisse rutrum orci sed molestie lacinia. Aliquam posuere eleifend massa faucibus gravida. Curabitur consequat nisi ut pellentesque volutpat. Suspendisse potenti [google](https://google.com).

- dash list 1
- dash list 2
- dash list 3

+ plus list 1
+ plus list 2
+ plus list 3

* star list 1
* star list 2
* star list 3

1. ordered 1
2. ordered 2
3. ordered 3

Praesent id leo lacus. Pellentesque malesuada velit dui, sit amet rhoncus mi congue tempor. Maecenas et orci ***vitae lacus gravida*** tristique ac et nibh. *Vivamus* eleifend tincidunt suscipit. Cras sed varius dui, ___maximus feugiat neque___. Ut ante turpis, ornare a nunc sit amet, dignissim gravida _leo_. Integer **vel** venenatis __justo__, congue faucibus ante. Morbi quis tristique mi. Duis lobortis sagittis lacus.

## Header 2

Vivamus at sem interdum, consectetur risus id, pellentesque dui. Maecenas non laoreet lectus. Maecenas eget dolor non ipsum tristique cursus a ut odio. Cras euismod eleifend aliquam. Donec semper scelerisque rutrum. Aenean auctor, nibh sed facilisis feugiat, leo enim accumsan nisi, ut convallis elit sem in purus. Mauris cursus facilisis tortor nec maximus. Sed consequat nec nunc cursus lobortis. Cras eleifend neque felis, vel tincidunt tellus aliquam at. Donec id pretium enim. Donec lacinia consequat lacus quis malesuada. Morbi rutrum, turpis quis molestie venenatis, urna nisl aliquam tortor, sed aliquam tortor lacus id risus. Sed gravida eget nisl sed pellentesque.

### Header 3

Ut gravida tempus velit, eu aliquet risus rutrum eu. Nullam auctor interdum velit sed fermentum. Nunc faucibus nisl leo, vel tempor nunc malesuada sodales. Fusce laoreet congue vehicula. Suspendisse et felis mi. Cras lacinia ex eget tempor feugiat. Phasellus luctus lacus quis pulvinar commodo.

#### Header 4

Maecenas id dignissim tellus. Donec ac magna consectetur, luctus felis id, pretium ex. Nulla eu libero risus. Nulla placerat nibh at nisi malesuada faucibus. Cras in mi at ligula placerat dignissim eu eu dolor. Praesent cursus augue sed pulvinar laoreet. Cras vestibulum dolor maximus suscipit venenatis. Nunc at urna ac odio pellentesque efficitur. Vestibulum nec magna mauris.

##### Header 5

Maecenas id dignissim tellus. Donec ac magna consectetur, luctus felis id, pretium ex. Nulla eu libero risus. Nulla placerat nibh at nisi malesuada faucibus. Cras in mi at ligula placerat dignissim eu eu dolor. Praesent cursus augue sed pulvinar laoreet.

###### Header 6

Maecenas id dignissim tellus. Donec ac magna consectetur, luctus felis id, pretium ex. Nulla eu libero risus. Nulla placerat nibh at nisi malesuada faucibus. Cras in mi at ligula placerat dignissim eu eu dolor. Praesent cursus augue sed pulvinar laoreet.

"""
        let exp = """
<h1>This is the title</h1>
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec neque commodo, aliquam nulla et, consectetur est. Nam nec tortor ut nisl pulvinar egestas sit amet ac magna. Duis viverra malesuada viverra. Mauris condimentum sem at nibh pellentesque condimentum. Fusce ut tellus eget diam pellentesque aliquam. Cras est massa, semper in nibh sit amet, lobortis pharetra ligula. Morbi cursus fermentum felis a fringilla. Praesent orci mi, interdum et pellentesque eget, dictum in mi. Praesent sagittis diam sit amet lectus <code>varius</code>, eget iaculis eros pharetra. Donec ligula lacus, auctor in tellus quis, elementum imperdiet lorem. Suspendisse rutrum orci sed molestie lacinia. Aliquam posuere eleifend massa faucibus gravida. Curabitur consequat nisi ut pellentesque volutpat. Suspendisse potenti <a href="https://google.com">google</a>.</p>
<ul>
<li>dash list 1</li>
<li>dash list 2</li>
<li>dash list 3</li>
</ul>
<ul>
<li>plus list 1</li>
<li>plus list 2</li>
<li>plus list 3</li>
</ul>
<ul>
<li>star list 1</li>
<li>star list 2</li>
<li>star list 3</li>
</ul>
<ol>
<li>ordered 1</li>
<li>ordered 2</li>
<li>ordered 3</li>
</ol>
<p>Praesent id leo lacus. Pellentesque malesuada velit dui, sit amet rhoncus mi congue tempor. Maecenas et orci <em><strong>vitae lacus gravida</strong></em> tristique ac et nibh. <em>Vivamus</em> eleifend tincidunt suscipit. Cras sed varius dui, <em><strong>maximus feugiat neque</strong></em>. Ut ante turpis, ornare a nunc sit amet, dignissim gravida <em>leo</em>. Integer <strong>vel</strong> venenatis <strong>justo</strong>, congue faucibus ante. Morbi quis tristique mi. Duis lobortis sagittis lacus.</p>
<h2>Header 2</h2>
<p>Vivamus at sem interdum, consectetur risus id, pellentesque dui. Maecenas non laoreet lectus. Maecenas eget dolor non ipsum tristique cursus a ut odio. Cras euismod eleifend aliquam. Donec semper scelerisque rutrum. Aenean auctor, nibh sed facilisis feugiat, leo enim accumsan nisi, ut convallis elit sem in purus. Mauris cursus facilisis tortor nec maximus. Sed consequat nec nunc cursus lobortis. Cras eleifend neque felis, vel tincidunt tellus aliquam at. Donec id pretium enim. Donec lacinia consequat lacus quis malesuada. Morbi rutrum, turpis quis molestie venenatis, urna nisl aliquam tortor, sed aliquam tortor lacus id risus. Sed gravida eget nisl sed pellentesque.</p>
<h3>Header 3</h3>
<p>Ut gravida tempus velit, eu aliquet risus rutrum eu. Nullam auctor interdum velit sed fermentum. Nunc faucibus nisl leo, vel tempor nunc malesuada sodales. Fusce laoreet congue vehicula. Suspendisse et felis mi. Cras lacinia ex eget tempor feugiat. Phasellus luctus lacus quis pulvinar commodo.</p>
<h4>Header 4</h4>
<p>Maecenas id dignissim tellus. Donec ac magna consectetur, luctus felis id, pretium ex. Nulla eu libero risus. Nulla placerat nibh at nisi malesuada faucibus. Cras in mi at ligula placerat dignissim eu eu dolor. Praesent cursus augue sed pulvinar laoreet. Cras vestibulum dolor maximus suscipit venenatis. Nunc at urna ac odio pellentesque efficitur. Vestibulum nec magna mauris.</p>
<h5>Header 5</h5>
<p>Maecenas id dignissim tellus. Donec ac magna consectetur, luctus felis id, pretium ex. Nulla eu libero risus. Nulla placerat nibh at nisi malesuada faucibus. Cras in mi at ligula placerat dignissim eu eu dolor. Praesent cursus augue sed pulvinar laoreet.</p>
<h6>Header 6</h6>
<p>Maecenas id dignissim tellus. Donec ac magna consectetur, luctus felis id, pretium ex. Nulla eu libero risus. Nulla placerat nibh at nisi malesuada faucibus. Cras in mi at ligula placerat dignissim eu eu dolor. Praesent cursus augue sed pulvinar laoreet.</p>
"""
        
        let html = try getHTML(input: input)
        #expect(html == exp)
    }
}

