//
//  XMLKeyedDecodingContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

extension _XMLDecoder.KeyedContainer: KeyedDecodingContainerProtocol {
    func getRaw(for key: Key) throws -> String {
        for raw in raws {
            let item = try _XMLDecoder.getKeyValue(text: raw)
            
            if item.key == key.stringValue {
                return item.value
            }
        }
        
        throw XMLDecoder.Error.keyNotFound(key: key.stringValue)
    }
    
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
        return KeyedDecodingContainer(try _XMLDecoder.KeyedContainer<NestedKey>(raw: getRaw(for: key), codingPath: codingPath + [key]))
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
