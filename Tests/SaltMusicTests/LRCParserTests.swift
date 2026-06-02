import XCTest
@testable import SaltMusic

final class LRCParserTests: XCTestCase {
    func testParsesMetadataAndTimedLines() {
        let text = """
        [ti:Song]
        [ar:Artist]
        [offset:500]
        [00:01.25]First line
        [00:03.50][00:04.50]Repeated line
        """

        let document = LRCParser.parse(text: text, source: .localLRC)

        XCTAssertEqual(document.title, "Song")
        XCTAssertEqual(document.artist, "Artist")
        XCTAssertEqual(document.offset, 0.5, accuracy: 0.001)
        XCTAssertEqual(document.lines.count, 3)
        XCTAssertEqual(document.lines[0].time, 1.25, accuracy: 0.001)
        XCTAssertEqual(document.lines[1].time, 3.5, accuracy: 0.001)
        XCTAssertEqual(document.lines[2].time, 4.5, accuracy: 0.001)
        XCTAssertEqual(document.lines[1].text, "Repeated line")
    }

    func testActiveLineUsesOffset() {
        let text = """
        [offset:1000]
        [00:02.00]Second line
        [00:04.00]Fourth line
        """

        let document = LRCParser.parse(text: text, source: .localLRC)

        XCTAssertEqual(document.activeLine(at: 0.9)?.text, nil)
        XCTAssertEqual(document.activeLine(at: 1.2)?.text, "Second line")
        XCTAssertEqual(document.activeLine(at: 3.1)?.text, "Fourth line")
    }
}
