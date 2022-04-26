//
//  CSVParser.swift
//  Parsers
//
//  Created by Yauheni on 4/25/22.
//

import Foundation
import Combine

class CSVDecoder: TopLevelDecoder {
    typealias Input = Data
    
    enum Error: Swift.Error {
        case wrongInputFormat
    }
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let raw = String(data: data, encoding: .utf8) else {
            throw CSVDecoder.Error.wrongInputFormat
        }
        
        let parser = CSVParser(raw: raw, codingPath: [])
        let container = try parser.singleValueContainer()
        return try container.decode(type)
    }
}

class CSVParser: Decoder {
    var raw: String
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    var keys: [String]
    
    init(raw: String, codingPath: [CodingKey], keys: [String] = []) {
        self.raw = raw
        self.codingPath = codingPath
        self.userInfo = [:]
        self.keys = keys
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
        
        init(raw: String, codingPath: [CodingKey], keys: [String] = []) {
            self.raw = raw
            self.codingPath = codingPath
            self.keys = keys
        }
        
        func decodeNil() -> Bool {
            return raw.isEmpty
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            guard let value = Bool(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: String.Type) throws -> String {
            return raw
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            guard let value = Double(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            guard let value = Float(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            guard let value = Int(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            guard let value = Int8(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            guard let value = Int16(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            guard let value = Int32(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            guard let value = Int64(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            guard let value = UInt(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            guard let value = UInt8(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            guard let value = UInt16(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            guard let value = UInt32(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            guard let value = UInt64(raw) else {
                throw CSVDecoder.Error.wrongInputFormat
            }
            
            return value
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T.init(from: CSVParser(raw: raw, codingPath: codingPath, keys: keys))
        }
    }
    
    class KeyedContainer<Key> where Key: CodingKey {
        var raws: [String]
        var codingPath: [CodingKey]
        var allKeys: [Key]
        
        init(raw: String, codingPath: [CodingKey], allKeys: [Key]) {
            self.raws = CSVParser.separated(raw: raw, separator: ",")
            self.codingPath = codingPath
            self.allKeys = allKeys
        }
    }
    
    class UnkeyedContainer: UnkeyedDecodingContainer {
        var raws: [String]
        
        var keysRow: [String]
        
        var codingPath: [CodingKey]
        var count: Int? {
            raws.count
        }
        var isAtEnd: Bool {
            currentIndex >= raws.count
        }
        var currentIndex: Int = 0
        
        init(raw: String, codingPath: [CodingKey]) {
            self.codingPath = codingPath
            self.raws = CSVParser.separated(raw: raw, separator: ",")
            self.keysRow = CSVParser.separated(raw: raws[0], separator: ",")
        }
        
        func decodeNil() throws -> Bool {
            return isAtEnd
        }
        
        func decode<T>(_ type: [T].Type) throws -> [T] where T: Decodable {
            let value = try [T].init(from: CSVParser(raw: raws[currentIndex], codingPath: codingPath))
            currentIndex += 1
            return value
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            if currentIndex == 0 {
                currentIndex = 1
            }
            let value = try T.init(from: CSVParser(raw: raws[currentIndex], codingPath: codingPath, keys: keysRow))
            currentIndex += 1
            return value
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let value = KeyedDecodingContainer(KeyedContainer<NestedKey>(raw: raws[currentIndex], codingPath: codingPath, allKeys: try keysRow.map {
                if let key = NestedKey(stringValue: $0) {
                    return key
                }
                
                throw CSVDecoder.Error.wrongInputFormat
            }))
            currentIndex += 1
            return value
        }
        
        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let value = UnkeyedContainer(raw: raws[currentIndex], codingPath: codingPath)
            currentIndex += 1
            return value
        }
        
        func superDecoder() throws -> Decoder {
            return CSVParser(raw: raws[currentIndex], codingPath: codingPath)
        }
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KeyedContainer<Key>(raw: raw, codingPath: codingPath, allKeys: try keys.map {
            if let key = Key(stringValue: $0) {
                return key
            }
            
            throw CSVDecoder.Error.wrongInputFormat
        }))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return UnkeyedContainer(raw: raw, codingPath: codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(raw: raw, codingPath: codingPath)
    }
    
    static func isEnded(item: String, separator: Character) -> Bool {
        if item.first == "\"" {
            return item.count >= 2 && item.last == "\""
        }
        
        return true
    }
}

extension CSVParser.KeyedContainer: KeyedDecodingContainerProtocol {
    func contains(_ key: Key) -> Bool {
        return false
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return true
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        guard let indexOfRaw = allKeys.firstIndex(where: { $0.stringValue == key.stringValue }) else {
            throw CSVDecoder.Error.wrongInputFormat
        }
        
        guard raws.count > indexOfRaw else {
            throw CSVDecoder.Error.wrongInputFormat
        }
        
        return try type.init(from: CSVParser(raw: raws[indexOfRaw], codingPath: codingPath))
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedDecodingContainer(CSVParser.KeyedContainer<NestedKey>(raw: raws.joined(separator: ","), codingPath: codingPath, allKeys: []))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return CSVParser.UnkeyedContainer(raw: raws.joined(separator: ","), codingPath: [])
    }
    
    func superDecoder() throws -> Decoder {
        return CSVParser(raw: raws.joined(separator: ","), codingPath: codingPath)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return CSVParser(raw: raws.joined(separator: ","), codingPath: codingPath)
    }
}
