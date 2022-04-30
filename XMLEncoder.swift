//
//  XMLEncoder.swift
//  Parsers
//
//  Created by Yauheni on 4/29/22.
//

import Foundation
import Combine

class XMLEncoder: BaseEncoder<Data> {
    enum Error: Swift.Error {
        case wrongOutput
    }
    
    override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let encoder = _XMLEncoder(codingPath: [], level: 0)
        
        var container = encoder.singleValueContainer()
        try container.encode(value)
        
        guard let data = encoder.raw.data(using: .utf8) else {
            throw Error.wrongOutput
        }
        return data
    }
}

class _XMLEncoder: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    
    var level: Int
    
    var container: EncodingContainer?
    var raw: String {
        container?.raw ?? ""
    }
    
    init(codingPath: [CodingKey], level: Int) {
        self.codingPath = codingPath
        self.userInfo = [:]
        self.level = level
    }
    
    static func addTag(key: String, value: String) -> String {
        return "<\(key)>\(value)</\(key)>"
    }
    
    class KeyedContainer<Key> where Key: CodingKey {
        var codingPath: [CodingKey]
        var raws: [String]
        var level: Int
        
        init(codingPath: [CodingKey], level: Int) {
            self.codingPath = codingPath
            self.raws = []
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
        var level: Int
        
        var container: EncodingContainer?
        
        var raw: String {
            if let container = container {
                return container.raw
            }
            
            return raws.map({ _XMLEncoder.addTag(key: "item", value: $0) }).joined()
        }
        
        init(codingPath: [CodingKey], level: Int) {
            self.codingPath = codingPath
            self.count = 0
            self.raws = []
            self.level = level
        }
        
        func encodeNil() throws {
            raws.append("")
        }
        
        func encode<T>(_ value: [T]) throws where T : Encodable {
            let encoder = _XMLEncoder(codingPath: codingPath + [ContainerKey(intValue: count)], level: level+1)
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
            raws.append(encoder.raw)
            count += 1
        }
        
        func encode<T>(_ value: T) throws where T : Encodable {
            let encoder = _XMLEncoder(codingPath: codingPath + [ContainerKey(intValue: count)], level: level+1)
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
            raws.append(encoder.raw)
            count += 1
        }
        
        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return KeyedEncodingContainer(KeyedContainer(codingPath: codingPath + [ContainerKey(intValue: count)], level: level+1))
        }
        
        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let container = UnkeyedContainer(codingPath: codingPath + [ContainerKey(intValue: count)], level: level+1)
            count += 1
            return container
        }
        
        func superEncoder() -> Encoder {
            return _XMLEncoder(codingPath: codingPath, level: level)
        }
    }
    
    class SingleValueContainer: SingleValueEncodingContainer, EncodingContainer {
        var codingPath: [CodingKey]
        var raw: String = ""
        var level: Int
        
        init(codingPath: [CodingKey], level: Int) {
            self.codingPath = codingPath
            self.level = level
        }
        
        func encodeNil() throws {
            raw = ""
        }
        
        func encode(_ value: Bool) throws {
            raw = String(value)
        }
        
        func encode(_ value: String) throws {
            raw = value
            
            if raw.contains(where: { ["\n", ","].contains($0) }) {
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
            let encoder = _XMLEncoder(codingPath: codingPath, level: level)
            try value.encode(to: encoder)
            self.raw = encoder.raw
        }
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = KeyedContainer<Key>(codingPath: codingPath, level: level)
        self.container = container
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = UnkeyedContainer(codingPath: codingPath, level: level)
        self.container = container
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = SingleValueContainer(codingPath: codingPath, level: level)
        self.container = container
        return container
    }
    
    
}

extension _XMLEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        raws.append(_XMLEncoder.addTag(key: key.stringValue, value: ""))
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let encoder = _XMLEncoder(codingPath: codingPath + [key], level: level + 1)
        
        var container = encoder.singleValueContainer()
        try container.encode(value)
        
        raws.append(_XMLEncoder.addTag(key: key.stringValue, value: encoder.raw))
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Keyed container cannot contain another keyed container in CSV")
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("Keyed container cannot contain array in CSV")
    }
    
    func superEncoder() -> Encoder {
        return _XMLEncoder(codingPath: codingPath, level: level)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return _XMLEncoder(codingPath: codingPath + [key], level: level + 1)
    }
}

extension _XMLEncoder.KeyedContainer: EncodingContainer {
    var raw: String {
        raws.joined()
    }
}
