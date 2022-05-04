//
//  TopLevelCSVDecoder.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

public class CSVDecoder: BaseDecoder<Data> {
    enum Error: LocalizedError {
        case keyNotFound(key: String)
        case missingItemInRow
        case wrongInputFormat
        case singleValueDecodingFailure
        case noKeysFound
        
        var errorDescription: String? {
            switch self {
            case .keyNotFound(let key):
                return "Key \"\(key)\" not found in the file"
            case .missingItemInRow:
                return "Missing item in row"
            case .wrongInputFormat:
                return "Wrong input"
            case .singleValueDecodingFailure:
                return "Unable to decode one of the values"
            case .noKeysFound:
                return "Wrong date/time format"
            }
        }
    }
    
    override public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let raw = String(data: data, encoding: .utf8) else {
            throw CSVDecoder.Error.wrongInputFormat
        }
        
        let parser = _CSVDecoder(raw: raw, codingPath: [], level: 0)
        let container = try parser.singleValueContainer()
        let value = try container.decode(type)
        
        return value
    }
}
