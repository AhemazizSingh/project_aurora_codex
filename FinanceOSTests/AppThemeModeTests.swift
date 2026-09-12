import XCTest
@testable import FinanceOS

final class AppThemeModeTests: XCTestCase {
    func testThemeModesHaveStableRawValues() {
        XCTAssertEqual(AppThemeMode.system.rawValue, "system")
        XCTAssertEqual(AppThemeMode.light.rawValue, "light")
        XCTAssertEqual(AppThemeMode.dark.rawValue, "dark")
    }
}
