//
//  Default.swift
//  omnii
//
//  Created by huyang on 2023/5/5.
//

import UIKit
import Foundation

public protocol DefaultValue {
    associatedtype Value
    static var defaultValue: Value { get }
}

@propertyWrapper
public struct DefaultCodable<T: DefaultValue>: Codable where T.Value: Codable {
    public var wrappedValue: T.Value
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(T.Value.self)
    }
    
    public init() {
        wrappedValue = T.defaultValue
    }
}

public extension KeyedDecodingContainer {
    func decode<T>(_ type: DefaultCodable<T>.Type, forKey key: Key) throws -> DefaultCodable<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

public extension KeyedEncodingContainer {
    mutating func encode<T>(_ value: DefaultCodable<T>, forKey key: Key) throws {
//        guard value.wrappedValue != T.defaultValue else { return }
        try encode(value.wrappedValue, forKey: key)
    }
}


// MARK: - convenient default value

public protocol EmptyInitializable { init() }

extension String: EmptyInitializable {}
extension Array: EmptyInitializable {}
extension Dictionary: EmptyInitializable {}

public enum CommonDefault {

    public struct `Self`<Value: DefaultValue>: DefaultValue {
        public static var defaultValue: Value {
            Value.defaultValue as! Value
        }
    }
    
    public struct Empty<Value: EmptyInitializable>: DefaultValue {
        public static var defaultValue: Value {
            .init()
        }
    }


    public struct Zero<Value: Numeric>: DefaultValue {
        public static var defaultValue: Value {
            .zero
        }
    }

    public struct One<Value: Numeric>: DefaultValue {
        public static var defaultValue: Value {
            1
        }
    }

    public struct MinusOne<Value: Numeric>: DefaultValue {
        public static var defaultValue: Value {
            -1
        }
    }

}

public extension Bool {

    public enum False: DefaultValue {
        public static let defaultValue = false
    }

    public enum True: DefaultValue {
        public static let defaultValue = true
    }

}

public extension Date {
    public enum Today: DefaultValue {
        public static let defaultValue = Date()
    }
}

public enum Default {
    public typealias True = DefaultCodable<Bool.True>
    public typealias False = DefaultCodable<Bool.False>

    public typealias Today = DefaultCodable<Date.Today>

    public typealias Empty<Value: Codable & EmptyInitializable> = DefaultCodable<CommonDefault.Empty<Value>>

    public typealias Zero<Value: Codable & Numeric> = DefaultCodable<CommonDefault.Zero<Value>>

    public typealias One<Value: Codable & Numeric> = DefaultCodable<CommonDefault.One<Value>>

    public typealias MinusOne<Value: Codable & Numeric> = DefaultCodable<CommonDefault.MinusOne<Value>>
    
    public typealias `Self`<Value: Codable & DefaultValue> = DefaultCodable<CommonDefault.Self<Value>>
}
