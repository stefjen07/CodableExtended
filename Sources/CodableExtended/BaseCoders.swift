//
//  BaseCoders.swift
//  Parsers
//
//  Created by Yauheni on 4/29/22.
//

import Foundation
import Combine

public class BaseDecoder<Input>: TopLevelDecoder {
    public func decode<T>(_ type: T.Type, from: Input) throws -> T where T : Decodable {
        fatalError("Base decoder is unable to decode")
    }
}

public class BaseEncoder<Output>: TopLevelEncoder {
    public func encode<T>(_ value: T) throws -> Output where T : Encodable {
        fatalError("Base encoder is unable to encode")
    }
}

protocol EncodingContainer {
    var raw: String { get }
}
