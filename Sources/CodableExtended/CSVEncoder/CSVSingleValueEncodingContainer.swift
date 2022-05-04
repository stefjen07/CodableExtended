//
//  CSVSingleValueEncodingContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

extension _CSVEncoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        raw = ""
    }
    
    func encode(_ value: Bool) throws {
        raw = String(value)
    }
    
    func encode(_ value: String) throws {
        raw = value
        
        if raw.contains(where: { ["\n", ","].contains($0) }) {
            raw = "\"" + raw + "\""
        }
    }
    
    func encode(_ value: Double) throws {
        raw = String(value)
    }
    
    func encode(_ value: Float) throws {
        raw = String(value)
    }
    
    func encode(_ value: Int) throws {
        raw = String(value)
    }
    
    func encode(_ value: Int8) throws {
        raw = String(value)
    }
    
    func encode(_ value: Int16) throws {
        raw = String(value)
    }
    
    func encode(_ value: Int32) throws {
        raw = String(value)
    }
    
    func encode(_ value: Int64) throws {
        raw = String(value)
    }
    
    func encode(_ value: UInt) throws {
        raw = String(value)
    }
    
    func encode(_ value: UInt8) throws {
        raw = String(value)
    }
    
    func encode(_ value: UInt16) throws {
        raw = String(value)
    }
    
    func encode(_ value: UInt32) throws {
        raw = String(value)
    }
    
    func encode(_ value: UInt64) throws {
        raw = String(value)
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = _CSVEncoder(codingPath: codingPath, level: level, keys: keys)
        try value.encode(to: encoder)
        self.raw = encoder.raw
    }
}
