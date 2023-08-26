//
//  WDParser.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

public protocol ModelType {
    init?(args: Any...) throws
}
public class ParserContext {
    // Future development for settings, callbacks, delegates, etc.
    public init() {}
}

public protocol Parser {
    associatedtype OutputType
    init(_ context: ParserContext)
    func parse(_ data: Data) -> (OutputType?, Error?)
}

public final class WDHTTPJSONParser<T: Decodable>: Parser {
    public init(_ context: ParserContext) {

    }
    public func parse(_ data: Data) -> (T?, Error?) {
        do {
            let jsonDecoder = JSONDecoder()

            do {
                let result: T = try jsonDecoder.decode(T.self, from: data)
                return (result, nil)
            } catch {
                return (nil, error)
            }
        }
    }
}
