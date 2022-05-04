//
//  XMLTopLevelEncoder.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

class XMLEncoder: BaseEncoder<Data> {
    enum Error: Swift.Error {
        case wrongOutput
    }
    
    override public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let encoder = _XMLEncoder(codingPath: [], level: 0)
        
        var container = encoder.singleValueContainer()
        try container.encode(value)
        
        guard let data = encoder.raw.data(using: .utf8) else {
            throw Error.wrongOutput
        }
        return data
    }
}
