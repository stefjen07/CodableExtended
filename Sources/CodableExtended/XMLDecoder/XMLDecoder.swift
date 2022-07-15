//
//  XMLParser.swift
//  Parsers
//
//  Created by Yauheni on 4/26/22.
//

import Foundation
import DequeModule

class _XMLDecoder: Decoder {
    var raw: String
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    
    init(raw: String, codingPath: [CodingKey]) {
        self.raw = raw
        self.codingPath = codingPath
        self.userInfo = [:]
    }
    
    static func separated(text: String) -> [String] {
        var result = [String]()
        
        var tagStack = Deque<String>()
        var currentTag = ""
        var currentRaw = ""
        
        for character in text {
            currentRaw.append(character)
            
            switch character {
            case "<":
                currentTag = "<"
			case " ":
				if currentTag.starts(with: "<") {
					tagStack.append(currentTag)
				}
            case ">":
                if currentTag[currentTag.index(currentTag.startIndex, offsetBy: 1)] == "/" && !tagStack.isEmpty {
                    _ = tagStack.popLast()
                    
                    if let last = tagStack.last {
                        currentTag = last
                    } else {
                        currentRaw.removeLast(currentTag.count + 1)
                        result.append(currentRaw)
                        
                        currentTag = ""
                        currentRaw = ""
                    }
                } else {
                    currentTag += ">"
                }
            default:
                if currentTag.last != ">" && currentTag.first == "<" {
                    currentTag.append(character)
                }
            }
        }
        
        return result
    }
    
    static func getKeyValue(text: String) throws -> (key: String, value: String) {
        var key = "", value = ""
        
        for character in text {
            if key.last == ">" {
                value.append(character)
            } else if character == "<" && key.isEmpty {
                key.append("<")
			} else if !key.isEmpty && key.last != " " {
                key.append(character)
			} else if !key.isEmpty && character == ">" {
				if key.last == " " {
					key.removeLast()
				}
				key.append(character)
			}
        }
        
        guard key.count > 2 else {
            throw XMLDecoder.Error.wrongKey
        }
        
        key.removeFirst()
        key.removeLast()
        
        return (key: key, value: value)
    }
    
    class KeyedContainer<Key> where Key: CodingKey {
        var raws: [String]
        var codingPath: [CodingKey]
        var allKeys: [Key]
        
        init(raw: String, codingPath: [CodingKey]) throws {
            self.codingPath = codingPath
            self.raws = _XMLDecoder.separated(text: raw)
            self.allKeys = try raws.map {
                let stringValue = try _XMLDecoder.getKeyValue(text: $0).key
                guard let key = Key(stringValue: stringValue) else {
                    throw XMLDecoder.Error.wrongKey
                }
                
                return key
            }
        }
    }
    
    class UnkeyedContainer {
        var raws: [String]
        
        var codingPath: [CodingKey]
        var count: Int? {
            raws.count
        }
        var isAtEnd: Bool {
            currentIndex >= raws.count
        }
        var currentIndex: Int = 0
        
        init(raw: String, codingPath: [CodingKey]) throws {
            self.codingPath = codingPath
            self.raws = try _XMLDecoder.separated(text: raw).map { try _XMLDecoder.getKeyValue(text: $0).value }
        }
    }
    
    class SingleValueContainer {
        var raw: String
        var codingPath: [CodingKey]
        
        init(raw: String, codingPath: [CodingKey]) {
            self.raw = raw
            self.codingPath = codingPath
        }
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(try KeyedContainer<Key>(raw: raw, codingPath: codingPath))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedContainer(raw: raw, codingPath: codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(raw: raw, codingPath: codingPath)
    }
}
