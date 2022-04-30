//
//  BaseCoders.swift
//  Parsers
//
//  Created by Yauheni on 4/29/22.
//

import Foundation
import Combine

class BaseDecoder<Input>: TopLevelDecoder {
    func decode<T>(_ type: T.Type, from: Input) throws -> T where T : Decodable {
        fatalError("Base decoder is unable to decode")
    }
}

class BaseEncoder<Output>: TopLevelEncoder {
    func encode<T>(_ value: T) throws -> Output where T : Encodable {
        fatalError("Base encoder is unable to encode")
    }
}

protocol EncodingContainer {
    var raw: String { get }
}
