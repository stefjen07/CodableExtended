//
//  XMLParser.swift
//  Parsers
//
//  Created by Yauheni on 4/26/22.
//

import Foundation
import Combine
import DequeModule

class XMLDecoder: BaseDecoder<Data> {
    enum Error: LocalizedError {
        case wrongInputFormat
        case wrongKey
        case singleValueDecodingFailure
        case keyNotFound(key: String)
        
        var errorDescription: String? {
            switch self {
            case .keyNotFound(let key):
                return "Key \"\(key)\" not found"
            case .wrongKey:
                return "Wrong key"
            case .wrongInputFormat:
                return "Wrong input format"
            case .singleValueDecodingFailure:
                return "Single value decoding failure"
            }
        }
    }
    
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let raw = String(data: data, encoding: .utf8) else {
            throw Error.wrongInputFormat
        }
        
        let decoder = _XMLDecoder(raw: raw, codingPath: [])
        let container = try decoder.singleValueContainer()
        let result = try container.decode(type)
        
        return result
    }
}

class _XMLDecoder: Decoder {
    var raw: String
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    
    init(raw: String, codingPath: [CodingKey]) {
        self.raw = raw
        self.codingPath = codingPath
        self.userInfo = [:]
    }
    
    static func separated(text: String) -> [String] {
        var result = [String]()
        
        var tagStack = Deque<String>()
        var currentTag = ""
        var currentRaw = ""
        
        for character in text {
            currentRaw.append(character)
            
            switch character {
            case "<":
                currentTag = "<"
            case ">":
                if currentTag[currentTag.index(currentTag.startIndex, offsetBy: 1)] == "/" && !tagStack.isEmpty {
                    tagStack.popLast()
                    
                    if let last = tagStack.last {
                        currentTag = last
                    } else {
                        currentRaw.removeLast(currentTag.count + 1)
                        result.append(currentRaw)
                        
                        currentTag = ""
                        currentRaw = ""
                    }
                } else {
                    currentTag += ">"
                    tagStack.append(currentTag)
                }
            default:
                if currentTag.last != ">" && currentTag.first == "<" {
                    currentTag.append(character)
                }
            }
        }
        
        return result
    }
    
    static func getKeyValue(text: String) throws -> (key: String, value: String) {
        var key = "", value = ""
        
        for character in text {
            if key.last == ">" {
                value.append(character)
            } else if character == "<" && key.isEmpty {
                key.append("<")
            } else if !key.isEmpty {
                key.append(character)
            }
        }
        
        guard key.count > 2 else {
            throw XMLDecoder.Error.wrongKey
        }
        
        key.removeFirst()
        key.removeLast()
        
        return (key: key, value: value)
    }
    
    class KeyedContainer<Key> where Key: CodingKey {
        var raws: [String]
        var codingPath: [CodingKey]
        var allKeys: [Key]
        
        func getRaw(for key: Key) throws -> String {
            for raw in raws {
                let item = try _XMLDecoder.getKeyValue(text: raw)
                
                if item.key == key.stringValue {
                    return item.value
                }
            }
            
            throw XMLDecoder.Error.keyNotFound(key: key.stringValue)
        }
        
        init(raw: String, codingPath: [CodingKey]) throws {
            self.codingPath = codingPath
            self.raws = _XMLDecoder.separated(text: raw)
            self.allKeys = try raws.map {
                let stringValue = try _XMLDecoder.getKeyValue(text: $0).key
                guard let key = Key(stringValue: stringValue) else {
                    throw XMLDecoder.Error.wrongKey
                }
                
                return key
            }
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
        
        var codingPath: [CodingKey]
        var count: Int? {
            raws.count
        }
        var isAtEnd: Bool {
            currentIndex >= raws.count
        }
        var currentIndex: Int = 0
        
        init(raw: String, codingPath: [CodingKey]) throws {
            self.codingPath = codingPath
            self.raws = try _XMLDecoder.separated(text: raw).map { try _XMLDecoder.getKeyValue(text: $0).value }
        }
        
        func decodeNil() throws -> Bool {
            return isAtEnd
        }
        
        func decode<T>(_ type: [T].Type) throws -> [T] where T: Decodable {
            let value = try [T].init(from: _XMLDecoder(raw: raws[currentIndex], codingPath: codingPath + [ContainerKey(intValue: currentIndex)]))
            currentIndex += 1
            return value
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            let value = try T.init(from: _XMLDecoder(raw: raws[currentIndex], codingPath: codingPath))
            currentIndex += 1
            return value
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let value = KeyedDecodingContainer(try KeyedContainer<NestedKey>(raw: raws[currentIndex], codingPath: codingPath))
            currentIndex += 1
            return value
        }
        
        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let value = try UnkeyedContainer(raw: raws[currentIndex], codingPath: codingPath)
            currentIndex += 1
            return value
        }
        
        func superDecoder() throws -> Decoder {
            return _XMLDecoder(raw: raws[currentIndex], codingPath: codingPath)
        }
    }
    
    class SingleValueContainer: SingleValueDecodingContainer {
        var raw: String
        var codingPath: [CodingKey]
        
        init(raw: String, codingPath: [CodingKey]) {
            self.raw = raw
            self.codingPath = codingPath
        }
        
        func decodeNil() -> Bool {
            return raw.isEmpty
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            guard let value = Bool(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: String.Type) throws -> String {
            return raw
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            guard let value = Double(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            guard let value = Float(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            guard let value = Int(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            guard let value = Int8(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            guard let value = Int16(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            guard let value = Int32(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            guard let value = Int64(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            guard let value = UInt(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            guard let value = UInt8(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            guard let value = UInt16(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            guard let value = UInt32(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            guard let value = UInt64(raw) else {
                throw XMLDecoder.Error.singleValueDecodingFailure
            }
            
            return value
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T.init(from: _XMLDecoder(raw: raw, codingPath: codingPath))
        }
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(try KeyedContainer<Key>(raw: raw, codingPath: codingPath))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedContainer(raw: raw, codingPath: codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(raw: raw, codingPath: codingPath)
    }
    
    
}

extension _XMLDecoder.KeyedContainer: KeyedDecodingContainerProtocol {
    func contains(_ key: Key) -> Bool {
        return false
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return true
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        return try type.init(from: _XMLDecoder(raw: getRaw(for: key), codingPath: codingPath + [key]))
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedDecodingContainer(try _XMLDecoder.KeyedContainer<NestedKey>(raw: getRaw(for: key), codingPath: codingPath + [key])) //FIXME
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try _XMLDecoder.UnkeyedContainer(raw: getRaw(for: key), codingPath: codingPath + [key])
    }
    
    func superDecoder() throws -> Decoder {
        return _XMLDecoder(raw: raws.joined(), codingPath: codingPath)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return _XMLDecoder(raw: raws.joined(), codingPath: codingPath + [key])
    }
}
