//
//  CSVEncoder.swift
//  Parsers
//
//  Created by Yauheni on 4/27/22.
//

import Foundation
import Combine

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
    
    class KeyedContainer<Key>: EncodingContainer where Key: CodingKey {
        var codingPath: [CodingKey]
        var raws: [String]
        var keys: [String]
        var level: Int
        
        var raw: String {
            raws.joined(separator: ",")
        }
        
        init(codingPath: [CodingKey], keys: [String], level: Int) {
            self.codingPath = codingPath
            self.raws = keys.map { _ in "" }
            self.keys = keys
            self.level = level
        }
    }
    
    class UnkeyedContainer: EncodingContainer {
        var codingPath: [CodingKey]
        var count: Int
        var raws: [String]
        var keys: [String]
        var level: Int
        
        var container: EncodingContainer?
        
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
    }
    
    class SingleValueContainer: EncodingContainer {
        var codingPath: [CodingKey]
        var raw: String = ""
        var level: Int
        var keys: [String]
        
        init(codingPath: [CodingKey], level: Int, keys: [String]) {
            self.codingPath = codingPath
            self.level = level
            self.keys = keys
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
