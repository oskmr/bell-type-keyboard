//
//  PokebellInputMapper.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import Foundation

class PokebellInputMapper {
    static let shared = PokebellInputMapper()

    private let mapping: [String: String] = [
        "11": "あ", "12": "い", "13": "う", "14": "え", "15": "お",
        "21": "か", "22": "き", "23": "く", "24": "け", "25": "こ",
        "31": "さ", "32": "し", "33": "す", "34": "せ", "35": "そ",
        "41": "た", "42": "ち", "43": "つ", "44": "て", "45": "と",
        "51": "な", "52": "に", "53": "ぬ", "54": "ね", "55": "の",
        "61": "は", "62": "ひ", "63": "ふ", "64": "へ", "65": "ほ",
        "71": "ま", "72": "み", "73": "む", "74": "め", "75": "も",
        "81": "や", "82": "ゆ", "83": "よ", "84": "わ", "85": "を",
        "91": "ら", "92": "り", "93": "る", "94": "れ", "95": "ろ", "96": "ん",
        "00": " "
    ]

    func getCharacter(firstDigit: Int, secondDigit: Int) -> String? {
        let key = "\(firstDigit)\(secondDigit)"
        return mapping[key]
    }

    func getCharactersForRow(row: Int) -> [(code: String, char: String)] {
        var result: [(String, String)] = []
        for col in 0...9 {
            let key = "\(row)\(col)"
            if let char = mapping[key] {
                result.append((key, char))
            }
        }
        return result
    }

    func getAllRows() -> [Int] {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    }
}
