//
//  CSVKeyedEncodingContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

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
