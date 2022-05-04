//
//  CSVUnkeyedContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

extension _CSVEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
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
    
    var separator: String {
        if level == 0 {
            return "\n"
        } else {
            return ","
        }
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
        let encoder = _CSVEncoder(codingPath: codingPath + [ContainerKey(intValue: count)], level: level+1, keys: keys)
        
        var container = encoder.singleValueContainer()
        try container.encode(value)
        
        raws.append(encoder.raw)
        count += 1
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedEncodingContainer(_CSVEncoder.KeyedContainer(codingPath: codingPath + [ContainerKey(intValue: count)], keys: keys, level: level+1))
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _CSVEncoder.UnkeyedContainer(codingPath: codingPath + [ContainerKey(intValue: count)], keys: keys, level: level+1)
        count += 1
        return container
    }
    
    func superEncoder() -> Encoder {
        return _CSVEncoder(codingPath: codingPath, level: level, keys: keys)
    }
}
