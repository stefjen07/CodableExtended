//
//  CSVParser.swift
//  Parsers
//
//  Created by Yauheni on 4/25/22.
//

import Foundation

class _CSVDecoder: Decoder {
    var raw: String
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    var keys: [String]
    var level: Int
    
    init(raw: String, codingPath: [CodingKey], keys: [String] = [], level: Int) {
        self.raw = raw
        self.codingPath = codingPath
        self.userInfo = [:]
        self.keys = keys
        self.level = level
    }
    
    static func separated(raw: String, separator: Character) -> [String] {
        var raws = [String]()
        var currentRow = ""
        var currentItem = ""
        
        for character in raw {
            switch character {
            case "\n":
                if isEnded(item: currentItem, separator: separator) {
                    if separator != "\n" {
                        return separated(raw: raw, separator: "\n")
                    }
                    if !currentItem.isEmpty {
                        currentRow += currentItem
                        currentItem = ""
                    }
                    if !currentRow.isEmpty {
                        raws.append(currentRow)
                        currentRow = ""
                    }
                } else {
                    currentItem += "\n"
                }
            case ",":
                if isEnded(item: currentItem, separator: separator) {
                    if separator == "," {
                        raws.append(currentItem)
                    } else {
                        currentItem += ","
                        currentRow += currentItem
                    }
                    currentItem = ""
                } else {
                    currentItem += ","
                }
            default:
                currentItem += String(character)
            }
        }
        
        if !currentItem.isEmpty {
            currentRow += currentItem
        }
        
        if !currentRow.isEmpty {
            raws.append(currentRow)
        }
        
        return raws
    }
    
    class SingleValueContainer {
        var raw: String
        var codingPath: [CodingKey]
        var keys: [String]
        var level: Int
        
        init(raw: String, codingPath: [CodingKey], keys: [String] = [], level: Int) {
            self.raw = raw
            self.codingPath = codingPath
            self.keys = keys
            self.level = level
        }
    }
    
    class KeyedContainer<Key> where Key: CodingKey {        
        var raws: [String]
        var codingPath: [CodingKey]
        var allKeys: [Key]
        var level: Int
        
        init(raw: String, codingPath: [CodingKey], allKeys: [Key], level: Int) {
            self.raws = _CSVDecoder.separated(raw: raw, separator: ",")
            self.codingPath = codingPath
            self.allKeys = allKeys
            self.level = level
        }
    }
    
    class UnkeyedContainer {
        var raws: [String]
        var keysRow: [String]
        var level: Int
        
        var codingPath: [CodingKey]
        var count: Int? {
            raws.count
        }
        var isAtEnd: Bool {
            currentIndex >= raws.count
        }
        var currentIndex: Int = 0
        
        init(raw: String, codingPath: [CodingKey], level: Int) throws {
            self.codingPath = codingPath
            
            self.level = level
            self.raws = _CSVDecoder.separated(raw: raw, separator: ",")
            guard let keysRaw = raws.first else {
                throw CSVDecoder.Error.noKeysFound
            }
            self.keysRow = _CSVDecoder.separated(raw: keysRaw, separator: ",")
        }
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KeyedContainer<Key>(
            raw: raw,
            codingPath: codingPath,
            allKeys: try keys.map {
                if let key = Key(stringValue: $0) {
                    return key
                }
                
                throw CSVDecoder.Error.wrongInputFormat
            },
            level: level
        ))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedContainer(raw: raw, codingPath: codingPath, level: level)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(raw: raw, codingPath: codingPath, level: level)
    }
    
    static func isEnded(item: String, separator: Character) -> Bool {
        if item.first == "\"" {
            return item.count >= 2 && item.last == "\""
        }
        
        return true
    }
}
