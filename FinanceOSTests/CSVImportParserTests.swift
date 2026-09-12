import XCTest
@testable import FinanceOS

final class CSVImportParserTests: XCTestCase {
    func testParsesExportShapeWithQuotedFields() throws {
        let csv = "\"Date\",\"Type\",\"Amount\",\"Currency\",\"From Account\",\"To Account\",\"Category\",\"Labels\",\"Notes\"\n\"2026-09-13T10:30:00Z\",\"expense\",\"250.50\",\"INR\",\"Main, Bank\",\"\",\"Food\",\"Weekend; Dining\",\"Lunch at \"\"Cafe\"\"\""

        let result = try CSVImportParser.parse(csv)

        guard case let .success(rows) = result, let row = rows.first else { return XCTFail("Expected a valid row") }
        XCTAssertEqual(row.type, .expense)
        XCTAssertEqual(row.amount, Decimal(string: "250.50"))
        XCTAssertEqual(row.sourceAccountName, "Main, Bank")
        XCTAssertEqual(row.labelNames, ["Weekend", "Dining"])
        XCTAssertEqual(row.notes, "Lunch at \"Cafe\"")
    }

    func testReportsMalformedRowsWithoutImportingAnyRows() throws {
        let csv = "Date,Type,Amount\n2026-09-13T10:30:00Z,expense,0\n2026-09-13T10:30:00Z,not-a-type,42"

        let result = try CSVImportParser.parse(csv)

        guard case let .failure(errors) = result else { return XCTFail("Expected row errors") }
        XCTAssertEqual(errors.count, 2)
    }
}
