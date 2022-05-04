//
//  XMLUnkeyedDecodingContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

extension _XMLDecoder.UnkeyedContainer: UnkeyedDecodingContainer {
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
        let value = KeyedDecodingContainer(try _XMLDecoder.KeyedContainer<NestedKey>(raw: raws[currentIndex], codingPath: codingPath))
        currentIndex += 1
        return value
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let value = try _XMLDecoder.UnkeyedContainer(raw: raws[currentIndex], codingPath: codingPath)
        currentIndex += 1
        return value
    }
    
    func superDecoder() throws -> Decoder {
        return _XMLDecoder(raw: raws[currentIndex], codingPath: codingPath)
    }
}
