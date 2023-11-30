//
//  ModelVisitor.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/10/23.
//

protocol Model {
    func accept<T:ModelVisitor>(_ visitor: T) -> T.ReturnType
}

protocol ModelVisitor {
    associatedtype ReturnType
    
    func visitBee(_ model: Bee) -> ReturnType
    func visitHive(_ model: Hive) -> ReturnType
    func visitHoneyStorage(_ model: HoneyStorage) -> ReturnType
    func visitPollenStorage(_ model: PollenStorage) -> ReturnType
    func visitIncubator(_ model: Incubator) -> ReturnType
    func visitFlower(_ model: Flower) -> ReturnType
}
