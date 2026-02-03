//
//  PokebellInputMapperTests.swift
//  bell-type-keyboard-exTests
//
//  Created by miseri.osaka on 2026/01/29.
//

import XCTest
@testable import bell_type_keyboard_ex

/// PokebellInputMapperTests validates row-0 mappings.
final class PokebellInputMapperTests: XCTestCase {
    /// Verifies that 0x mappings include わ, を, ん, and space.
    ///
    /// Example:
    /// ```swift
    /// let mapper = PokebellInputMapper.shared
    /// XCTAssertEqual(mapper.getCharacter(firstDigit: 0, secondDigit: 1), "わ")
    /// ```
    func testZeroRowMappings() {
        let mapper = PokebellInputMapper.shared

        XCTAssertEqual(mapper.getCharacter(firstDigit: 0, secondDigit: 0), " ")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 0, secondDigit: 1), "わ")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 0, secondDigit: 2), "を")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 0, secondDigit: 3), "ん")
    }
}
