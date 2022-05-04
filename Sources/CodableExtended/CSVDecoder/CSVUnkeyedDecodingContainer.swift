//
//  CSVUnkeyedContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

extension _CSVDecoder.UnkeyedContainer: UnkeyedDecodingContainer {
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
        let value = KeyedDecodingContainer(_CSVDecoder.KeyedContainer<NestedKey>(raw: raws[currentIndex], codingPath: codingPath, allKeys: try keysRow.map {
            if let key = NestedKey(stringValue: $0) {
                return key
            }
            
            throw CSVDecoder.Error.wrongInputFormat
        }, level: level))
        currentIndex += 1
        return value
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let value = try _CSVDecoder.UnkeyedContainer(raw: raws[currentIndex], codingPath: codingPath, level: level + 1)
        currentIndex += 1
        return value
    }
    
    func superDecoder() throws -> Decoder {
        return _CSVDecoder(raw: raws[currentIndex], codingPath: codingPath, level: level)
    }
}
