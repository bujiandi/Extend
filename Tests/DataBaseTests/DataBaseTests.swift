import XCTest
@testable import DataBase

final class DataBaseTests: XCTestCase {
    
    func testDebugFlag() {
        
        XCTAssertEqual(Extent.isRelease, false)
    }
    
    func testExample() {
        let path:Path = "Users/Swift/CodeSpaces/Swift/CustomLib/HTTP/"
        XCTAssertEqual(path.absolute, "/Users/Swift/CodeSpaces/Swift/CustomLib/HTTP")
    }
    
    func testFileName() {
        let path:Path = "Users/Swift/CodeSpaces/Swift/CustomLib/HTTP/"
        XCTAssertEqual(path.fileName, "HTTP")
    }
    
    func testFileExten() {
        let path:Path = "Users/Swift/CodeSpaces/Swift/CustomLib/HTTP/"
        XCTAssertEqual(path.fileExtension, "HTTP")
    }
    
    func testFileExten2() {
        let path:Path = "Users/Swift/CodeSpaces/Swift/CustomLib/HTTP.swift?haha"
        XCTAssertEqual(path.fileExtension, "swift")
    }
    
    func testFileSize() {
        let path:Path = "Users/Swift/CodeSpaces/Swift/CustomLib/HTTP/Exports.swift"
        XCTAssertFalse(path.fileSize() == 0)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
