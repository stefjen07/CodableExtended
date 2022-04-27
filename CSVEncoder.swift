//
//  CSVEncoder.swift
//  Parsers
//
//  Created by Yauheni on 4/27/22.
//

import Foundation
import Combine

class CSVEncoder: TopLevelEncoder {
    typealias Output = Data
    
    var keys: [String]
    init(keys: [String]) {
        self.keys = keys
    }
    
    enum Error: Swift.Error {
        case wrongOutput
    }
    
    func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let encoder = _CSVEncoder(codingPath: [], level: 0, keys: keys)
        
        var container = encoder.singleValueContainer()
        try container.encode(value)
        
        guard let raw = encoder.raw.data(using: .utf8) else {
            throw Error.wrongOutput
        }
        
        return raw
    }
}

protocol EncodingContainer {
    var raw: String { get }
}

class _CSVEncoder: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    var keys: [String]
    
    var level: Int
    
    var container: EncodingContainer?
    var raw: String {
        container?.raw ?? ""
    }
    
    init(codingPath: [CodingKey], level: Int, keys: [String]) {
        self.codingPath = codingPath
        self.userInfo = [:]
        self.keys = keys
        self.level = level
    }
    
    class KeyedContainer<Key> where Key: CodingKey {
        var codingPath: [CodingKey]
        var raws: [String]
        var keys: [String]
        var level: Int
        
        init(codingPath: [CodingKey], keys: [String], level: Int) {
            self.codingPath = codingPath
            self.raws = keys.map { _ in "" }
            self.keys = keys
            self.level = level
        }
    }
    
    class UnkeyedContainer: UnkeyedEncodingContainer, EncodingContainer {
        struct ContainerKey: CodingKey {
            var stringValue: String
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            
            var intValue: Int?
            init(intValue: Int) {
                self.intValue = intValue
                self.stringValue = String(intValue)
            }
        }
        
        var codingPath: [CodingKey]
        var count: Int
        var raws: [String]
        var keys: [String]
        var level: Int
        
        var container: EncodingContainer?
        var separator: String {
            if level == 0 {
                return "\n"
            } else {
                return ","
            }
        }
        
        var raw: String {
            if let container = container {
                return container.raw
            }
            
            return raws.joined(separator: separator)
        }
        
        init(codingPath: [CodingKey], keys: [String], level: Int) {
            self.codingPath = codingPath
            self.keys = keys
            self.count = 0
            self.raws = []
            self.level = level
        }
        
        func encodeNil() throws {
            raws.append("")
        }
        
        func encode<T>(_ value: [T]) throws where T : Encodable {
            let encoder = _CSVEncoder(codingPath: codingPath + [ContainerKey(intValue: count)], level: level+1, keys: keys)
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
            raws.append(encoder.raw)
            count += 1
        }
        
        func encode<T>(_ value: T) throws where T : Encodable {
            if count == 0 {
                
                count = 1
            }
            
            let encoder = _CSVEncoder(codingPath: codingPath + [ContainerKey(intValue: count)], level: level+1, keys: keys)
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
            raws.append(encoder.raw)
            count += 1
        }
        
        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return KeyedEncodingContainer(KeyedContainer(codingPath: codingPath + [ContainerKey(intValue: count)], keys: keys, level: level+1))
        }
        
        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let container = UnkeyedContainer(codingPath: codingPath + [ContainerKey(intValue: count)], keys: keys, level: level+1)
            count += 1
            return container
        }
        
        func superEncoder() -> Encoder {
            return _CSVEncoder(codingPath: codingPath, level: level, keys: keys)
        }
    }
    
    class SingleValueContainer: SingleValueEncodingContainer, EncodingContainer {
        var codingPath: [CodingKey]
        var raw: String = ""
        var level: Int
        var keys: [String]
        
        init(codingPath: [CodingKey], level: Int, keys: [String]) {
            self.codingPath = codingPath
            self.level = level
            self.keys = keys
        }
        
        func encodeNil() throws {
            raw = ""
        }
        
        func encode(_ value: Bool) throws {
            raw = String(value)
        }
        
        func encode(_ value: String) throws {
            raw = value
            
            if raw.contains("\n") {
                raw = "\"" + raw + "\""
            }
        }
        
        func encode(_ value: Double) throws {
            raw = String(value)
        }
        
        func encode(_ value: Float) throws {
            raw = String(value)
        }
        
        func encode(_ value: Int) throws {
            raw = String(value)
        }
        
        func encode(_ value: Int8) throws {
            raw = String(value)
        }
        
        func encode(_ value: Int16) throws {
            raw = String(value)
        }
        
        func encode(_ value: Int32) throws {
            raw = String(value)
        }
        
        func encode(_ value: Int64) throws {
            raw = String(value)
        }
        
        func encode(_ value: UInt) throws {
            raw = String(value)
        }
        
        func encode(_ value: UInt8) throws {
            raw = String(value)
        }
        
        func encode(_ value: UInt16) throws {
            raw = String(value)
        }
        
        func encode(_ value: UInt32) throws {
            raw = String(value)
        }
        
        func encode(_ value: UInt64) throws {
            raw = String(value)
        }
        
        func encode<T>(_ value: T) throws where T : Encodable {
            let encoder = _CSVEncoder(codingPath: codingPath, level: level, keys: keys)
            try value.encode(to: encoder)
            self.raw = encoder.raw
        }
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = KeyedContainer<Key>(codingPath: codingPath, keys: keys, level: level)
        self.container = container
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = UnkeyedContainer(codingPath: codingPath, keys: keys, level: level)
        self.container = container
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = SingleValueContainer(codingPath: codingPath, level: level, keys: keys)
        self.container = container
        return container
    }
    
    
}

extension _CSVEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        guard let index = keys.firstIndex(where: { key.stringValue == $0 }) else {
            throw CSVEncoder.Error.wrongOutput
        }
        
        raws[index] = ""
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        guard let index = keys.firstIndex(where: { key.stringValue == $0 }) else {
            throw CSVEncoder.Error.wrongOutput
        }
        
        let encoder = _CSVEncoder(codingPath: codingPath + [key], level: level + 1, keys: keys)
        
        var container = encoder.singleValueContainer()
        try container.encode(value)
        
        raws[index] = encoder.raw
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Keyed container cannot contain another keyed container in CSV")
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("Keyed container cannot contain array in CSV")
    }
    
    func superEncoder() -> Encoder {
        return _CSVEncoder(codingPath: codingPath, level: level, keys: keys)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return _CSVEncoder(codingPath: codingPath + [key], level: level + 1, keys: keys)
    }
}

extension _CSVEncoder.KeyedContainer: EncodingContainer {
    var raw: String {
        raws.joined(separator: ",")
    }
}
