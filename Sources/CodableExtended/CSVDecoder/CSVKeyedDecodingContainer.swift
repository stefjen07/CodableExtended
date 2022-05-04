//
//  CSVKeyedContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

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
