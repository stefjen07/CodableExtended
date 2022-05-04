//
//  XMLTopLevelDecoder.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

public class XMLDecoder: BaseDecoder<Data> {
    enum Error: LocalizedError {
        case wrongInputFormat
        case wrongKey
        case singleValueDecodingFailure
        case keyNotFound(key: String)
        
        var errorDescription: String? {
            switch self {
            case .keyNotFound(let key):
                return "Key \"\(key)\" not found"
            case .wrongKey:
                return "Wrong key"
            case .wrongInputFormat:
                return "Wrong input format"
            case .singleValueDecodingFailure:
                return "Single value decoding failure"
            }
        }
    }
    
    override public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let raw = String(data: data, encoding: .utf8) else {
            throw Error.wrongInputFormat
        }
        
        let decoder = _XMLDecoder(raw: raw, codingPath: [])
        let container = try decoder.singleValueContainer()
        let result = try container.decode(type)
        
        return result
    }
}
