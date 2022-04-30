//
//  CSVParser.swift
//  Parsers
//
//  Created by Yauheni on 4/25/22.
//

import Foundation
import Combine

class CSVDecoder: BaseDecoder<Data> {
    enum Error: LocalizedError {
        case keyNotFound(key: String)
        case missingItemInRow
        case wrongInputFormat
        case singleValueDecodingFailure
        case noKeysFound
        
        var errorDescription: String? {
            switch self {
            case .keyNotFound(let key):
                return "Key \"\(key)\" not found in the file"
            case .missingItemInRow:
                return "Missing item in row"
            case .wrongInputFormat:
                return "Wrong input"
            case .singleValueDecodingFailure:
                return "Unable to decode one of the values"
            case .noKeysFound:
                return "Wrong date/time format"
            }
        }
    }
    
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let raw = String(data: data, encoding: .utf8) else {
            throw CSVDecoder.Error.wrongInputFormat
        }
        
        let parser = _CSVDecoder(raw: raw, codingPath: [], level: 0)
        let container = try parser.singleValueContainer()
        let value = try container.decode(type)
        
        return value
    }
}

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
    
    class SingleValueContainer: SingleValueDecodingContainer {
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
        
        func decodeNil() -> Bool {
            return raw.isEmpty
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            guard let value = Bool(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: String.Type) throws -> String {
            var value = raw
            if value.first == "\"" && value.last == "\"" && value.count > 1 {
                value.removeFirst()
                value.removeLast()
                value = value.replacingOccurrences(of: "\"\"", with: "\"")
            }
            return value
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            guard let value = Double(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            guard let value = Float(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            guard let value = Int(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            guard let value = Int8(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            guard let value = Int16(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            guard let value = Int32(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            guard let value = Int64(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            guard let value = UInt(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            guard let value = UInt8(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            guard let value = UInt16(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            guard let value = UInt32(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            guard let value = UInt64(raw) else {
                throw CSVDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T.init(from: _CSVDecoder(raw: raw, codingPath: codingPath, keys: keys, level: level))
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
    
    class UnkeyedContainer: UnkeyedDecodingContainer {
        struct ContainerKey: CodingKey {
            var stringValue: String
            init?(stringValue: String) {
                return nil
            }
            
            var intValue: Int?
            init(intValue: Int) {
                self.intValue = intValue
                self.stringValue = String(intValue)
            }
        }
        
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
        
        func decodeNil() throws -> Bool {
            return isAtEnd
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            var isArray = false
            
            do {
                let tempValue = try T.init(from: _CSVDecoder(raw: raws[currentIndex], codingPath: codingPath, keys: keysRow, level: level+1))
                isArray = tempValue is Array<Any>
            } catch {
                isArray = false
            }
            
            if currentIndex == 0 && level == 0 && !isArray {
                currentIndex = 1
            }
            let value = try T.init(from: _CSVDecoder(raw: raws[currentIndex], codingPath: codingPath, keys: keysRow, level: level+1))
            currentIndex += 1
            return value
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let value = KeyedDecodingContainer(KeyedContainer<NestedKey>(raw: raws[currentIndex], codingPath: codingPath, allKeys: try keysRow.map {
                if let key = NestedKey(stringValue: $0) {
                    return key
                }
                
                throw CSVDecoder.Error.wrongInputFormat
            }, level: level))
            currentIndex += 1
            return value
        }
        
        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let value = try UnkeyedContainer(raw: raws[currentIndex], codingPath: codingPath, level: level + 1)
            currentIndex += 1
            return value
        }
        
        func superDecoder() throws -> Decoder {
            return _CSVDecoder(raw: raws[currentIndex], codingPath: codingPath, level: level)
        }
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KeyedContainer<Key>(raw: raw, codingPath: codingPath, allKeys: try keys.map {
            if let key = Key(stringValue: $0) {
                return key
            }
            
            throw CSVDecoder.Error.wrongInputFormat
        }, level: level))
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

extension _CSVDecoder.KeyedContainer: KeyedDecodingContainerProtocol {
    func contains(_ key: Key) -> Bool {
        return false
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return true
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        guard let indexOfRaw = allKeys.firstIndex(where: { $0.stringValue == key.stringValue }) else {
            throw CSVDecoder.Error.keyNotFound(key: key.stringValue)
        }
        
        guard raws.count > indexOfRaw else {
            throw CSVDecoder.Error.missingItemInRow
        }
        
        return try type.init(from: _CSVDecoder(raw: raws[indexOfRaw], codingPath: codingPath + [key], level: level+1))
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedDecodingContainer(_CSVDecoder.KeyedContainer<NestedKey>(raw: raws.joined(separator: ","), codingPath: codingPath + [key], allKeys: [], level: level+1))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try _CSVDecoder.UnkeyedContainer(raw: raws.joined(separator: ","), codingPath: codingPath + [key], level: level+1)
    }
    
    func superDecoder() throws -> Decoder {
        return _CSVDecoder(raw: raws.joined(separator: ","), codingPath: codingPath, level: level)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return _CSVDecoder(raw: raws.joined(separator: ","), codingPath: codingPath + [key], level: level+1)
    }
}
