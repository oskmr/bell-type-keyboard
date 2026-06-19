//
//  PokebellInputMapper.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import Foundation

final class PokebellInputMapper {
    static let shared = PokebellInputMapper()

    private let mapping: [String: String] = [
        "11": "あ", "12": "い", "13": "う", "14": "え", "15": "お", "16": "A", "17": "B", "18": "C", "19": "D", "10": "E",
        "21": "か", "22": "き", "23": "く", "24": "け", "25": "こ", "26": "F", "27": "G", "28": "H", "29": "I", "20": "J",
        "31": "さ", "32": "し", "33": "す", "34": "せ", "35": "そ", "36": "K", "37": "L", "38": "M", "39": "N", "30": "O",
        "41": "た", "42": "ち", "43": "つ", "44": "て", "45": "と", "46": "P", "47": "Q", "48": "R", "49": "S", "40": "T",
        "51": "な", "52": "に", "53": "ぬ", "54": "ね", "55": "の", "56": "U", "57": "V", "58": "W", "59": "X", "50": "Y",
        "61": "は", "62": "ひ", "63": "ふ", "64": "へ", "65": "ほ", "66": "Z", "67": "？", "68": "！", "69": "－", "60": "／",
        "71": "ま", "72": "み", "73": "む", "74": "め", "75": "も", "76": "￥", "77": "＆",
        "81": "や", "82": "（", "83": "ゆ", "84": "）", "85": "よ", "86": "＊", "87": "＃", "88": " ", "80": "小",
        "91": "ら", "92": "り", "93": "る", "94": "れ", "95": "ろ", "96": "1", "97": "2", "98": "3", "99": "4", "90": "5",
        "01": "わ", "02": "を", "03": "ん", "04": "゛", "05": "゜", "06": "6", "07": "7", "08": "8", "09": "9", "00": "0"
    ]

    private let dakutenMap: [Character: Character] = [
        "か": "が", "き": "ぎ", "く": "ぐ", "け": "げ", "こ": "ご",
        "さ": "ざ", "し": "じ", "す": "ず", "せ": "ぜ", "そ": "ぞ",
        "た": "だ", "ち": "ぢ", "つ": "づ", "て": "で", "と": "ど",
        "は": "ば", "ひ": "び", "ふ": "ぶ", "へ": "べ", "ほ": "ぼ",
        "う": "ゔ",
    ]

    private let handakutenMap: [Character: Character] = [
        "は": "ぱ", "ひ": "ぴ", "ふ": "ぷ", "へ": "ぺ", "ほ": "ぽ",
    ]

    private let smallKanaMap: [Character: Character] = [
        "あ": "ぁ", "い": "ぃ", "う": "ぅ", "え": "ぇ", "お": "ぉ",
        "や": "ゃ", "ゆ": "ゅ", "よ": "ょ",
        "つ": "っ", "わ": "ゎ",
    ]

    func getCharacter(firstDigit: Int, secondDigit: Int) -> String? {
        let key = "\(firstDigit)\(secondDigit)"
        return mapping[key]
    }

    func applyDakuten(to character: Character) -> Character? {
        return dakutenMap[character]
    }

    func applyHandakuten(to character: Character) -> Character? {
        return handakutenMap[character]
    }

    func applySmallKana(to character: Character) -> Character? {
        return smallKanaMap[character]
    }

    func isDakuten(firstDigit: Int, secondDigit: Int) -> Bool {
        return firstDigit == 0 && secondDigit == 4
    }

    func isHandakuten(firstDigit: Int, secondDigit: Int) -> Bool {
        return firstDigit == 0 && secondDigit == 5
    }

    func isSmallKana(firstDigit: Int, secondDigit: Int) -> Bool {
        return firstDigit == 8 && secondDigit == 0
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
