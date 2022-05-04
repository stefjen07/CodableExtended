//
//  XMLSingleValueDecodingContainer.swift
//  Parsers
//
//  Created by Евгений on 1.05.22.
//

import Foundation

extension _XMLDecoder.SingleValueContainer: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        return raw.isEmpty
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        guard let value = Bool(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: String.Type) throws -> String {
        return raw
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        guard let value = Double(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        guard let value = Float(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        guard let value = Int(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        guard let value = Int8(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        guard let value = Int16(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        guard let value = Int32(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        guard let value = Int64(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        guard let value = UInt(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard let value = UInt8(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard let value = UInt16(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard let value = UInt32(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard let value = UInt64(raw) else {
            throw XMLDecoder.Error.singleValueDecodingFailure
        }
        
        return value
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T.init(from: _XMLDecoder(raw: raw, codingPath: codingPath))
    }
}
