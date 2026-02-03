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

    func testDakutenDetection() {
        let mapper = PokebellInputMapper.shared

        XCTAssertTrue(mapper.isDakuten(firstDigit: 0, secondDigit: 4))
        XCTAssertFalse(mapper.isDakuten(firstDigit: 0, secondDigit: 5))
        XCTAssertFalse(mapper.isDakuten(firstDigit: 1, secondDigit: 4))
    }

    func testHandakutenDetection() {
        let mapper = PokebellInputMapper.shared

        XCTAssertTrue(mapper.isHandakuten(firstDigit: 0, secondDigit: 5))
        XCTAssertFalse(mapper.isHandakuten(firstDigit: 0, secondDigit: 4))
        XCTAssertFalse(mapper.isHandakuten(firstDigit: 1, secondDigit: 5))
    }

    func testApplyDakuten() {
        let mapper = PokebellInputMapper.shared

        XCTAssertEqual(mapper.applyDakuten(to: "か"), "が" as Character)
        XCTAssertEqual(mapper.applyDakuten(to: "し"), "じ" as Character)
        XCTAssertEqual(mapper.applyDakuten(to: "つ"), "づ" as Character)
        XCTAssertEqual(mapper.applyDakuten(to: "は"), "ば" as Character)
        XCTAssertEqual(mapper.applyDakuten(to: "う"), "ゔ" as Character)
        XCTAssertNil(mapper.applyDakuten(to: "あ"))
        XCTAssertNil(mapper.applyDakuten(to: "な"))
    }

    func testApplyHandakuten() {
        let mapper = PokebellInputMapper.shared

        XCTAssertEqual(mapper.applyHandakuten(to: "は"), "ぱ" as Character)
        XCTAssertEqual(mapper.applyHandakuten(to: "ひ"), "ぴ" as Character)
        XCTAssertEqual(mapper.applyHandakuten(to: "ふ"), "ぷ" as Character)
        XCTAssertEqual(mapper.applyHandakuten(to: "へ"), "ぺ" as Character)
        XCTAssertEqual(mapper.applyHandakuten(to: "ほ"), "ぽ" as Character)
        XCTAssertNil(mapper.applyHandakuten(to: "か"))
        XCTAssertNil(mapper.applyHandakuten(to: "あ"))
    }

    func testSymbolMappings() {
        let mapper = PokebellInputMapper.shared

        XCTAssertEqual(mapper.getCharacter(firstDigit: 6, secondDigit: 7), "？")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 6, secondDigit: 8), "！")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 6, secondDigit: 9), "／")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 7, secondDigit: 6), "￥")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 7, secondDigit: 7), "＆")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 8, secondDigit: 2), "（")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 8, secondDigit: 3), "ゆ")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 8, secondDigit: 4), "）")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 8, secondDigit: 6), "＊")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 8, secondDigit: 7), "＃")
        XCTAssertEqual(mapper.getCharacter(firstDigit: 8, secondDigit: 8), " ")
    }
}
