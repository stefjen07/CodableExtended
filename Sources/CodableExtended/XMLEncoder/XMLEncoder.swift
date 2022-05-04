//
//  XMLEncoder.swift
//  Parsers
//
//  Created by Yauheni on 4/29/22.
//

import Foundation

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
    
    class KeyedContainer<Key>: EncodingContainer where Key: CodingKey {
        var codingPath: [CodingKey]
        var raws: [String]
        var level: Int
        
        var raw: String {
            raws.joined()
        }
        
        init(codingPath: [CodingKey], level: Int) {
            self.codingPath = codingPath
            self.raws = []
            self.level = level
        }
    }
    
    class UnkeyedContainer: EncodingContainer {
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
    }
    
    class SingleValueContainer: EncodingContainer {
        var codingPath: [CodingKey]
        var raw: String = ""
        var level: Int
        
        init(codingPath: [CodingKey], level: Int) {
            self.codingPath = codingPath
            self.level = level
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
