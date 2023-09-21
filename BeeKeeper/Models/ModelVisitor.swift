//
//  ModelVisitor.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/10/23.
//

protocol Model {
    func accept<T:ModelVisitor>(_ visitor: T) -> T.ReturnType
}

public protocol ModelVisitor {
    associatedtype ReturnType
    
    func visitBee(_ model: Bee) -> ReturnType
    func visitHive(_ model: Hive) -> ReturnType
    func visitHoneycomb(_ model: Honeycomb) -> ReturnType
}
