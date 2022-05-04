//
//  XMLKeyedEncodingContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

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
