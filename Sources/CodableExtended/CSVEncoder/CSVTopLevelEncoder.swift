//
//  CSVTopLevelEncoder.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

public class CSVEncoder: BaseEncoder<Data> {
    var keys: [String]
    init(keys: [String]) {
        self.keys = keys
    }
    
    enum Error: Swift.Error {
        case wrongOutput
    }
    
    override public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let encoder = _CSVEncoder(codingPath: [], level: 0, keys: keys)
        
        var container = encoder.singleValueContainer()
        try container.encode(value)
        
        var raw = encoder.raw
        raw = keys.joined(separator: ",") + "\n" + raw
        if keys.isEmpty {
            raw.removeFirst()
        }
        
        guard let data = raw.data(using: .utf8) else {
            throw Error.wrongOutput
        }
        return data
    }
}
