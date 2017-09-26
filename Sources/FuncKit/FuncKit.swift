//
//  FuncKit.swift
//  FuncKit
//
//  Created by Xiaoxing Hu on 23/03/17.
//
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

extension Result {
    public func map<U>(f: (T)->U) -> Result<U> {
        switch self {
        case .success(let t): return .success(f(t))
        case .failure(let err): return .failure(err)
        }
    }
    public func flatMap<U>(f: (T)->Result<U>) -> Result<U> {
        switch self {
        case .success(let t): return f(t)
        case .failure(let err): return .failure(err)
        }
    }
    
    public func apply<U>(_ f: Result<((T) -> U)>) -> Result<U> {
        switch f {
        case .success(let _f): return self.map(f: _f)
        case .failure(let err): return .failure(err)
        }
    }
    
    public var value: T? {
        switch self {
        case .success(let v): return v
        case .failure: return nil
        }
    }
}

precedencegroup MonadicPrecedenceLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

infix operator |> : MonadicPrecedenceLeft
infix operator >>- : MonadicPrecedenceLeft
infix operator <*> : MonadicPrecedenceLeft
infix operator <^> : MonadicPrecedenceLeft

public func <^> <T, U>(f: (T) -> U, a: Result<T>) -> Result<U> {
    return a.map(f: f)
}

public func >>- <T, U>(a: Result<T>, f: (T) -> Result<U>) -> Result<U> {
    return a.flatMap(f: f)
}

public func |> <T, U, V>(f: @escaping (T) -> Result<U>, g: @escaping (U) -> Result<V>) -> (T) -> Result<V> {
    return { x in f(x) >>- g }
}

public func <*> <T, U>(f: Result<((T) -> U)>, a: Result<T>) -> Result<U> {
    return a.apply(f)
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in
        { b in
            f(a, b) } }
}

public func curry<A, B, C, D>(_ function: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { (a: A) -> (B) -> (C) -> D in
        { (b: B) -> (C) -> D in
            { (c: C) -> D in
                function(a, b, c) } } }
}

public func curry<A, B, C, D, E>(_ function: @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
    return { (a: A) -> (B) -> (C) -> (D) -> E in { (b: B) -> (C) -> (D) -> E in { (c: C) -> (D) -> E in { (d: D) -> E in function(a, b, c, d) } } } }
}

