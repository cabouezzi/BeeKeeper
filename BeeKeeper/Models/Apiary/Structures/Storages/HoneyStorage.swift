//
//  HoneyStorage.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import Foundation

public final class HoneyStorage: Structure {
    public private(set) var honey: Int = 0
    public private(set) var maximum: Int = 5000
    
    public required init() {
        super.init()
        self.name = "HoneyStorage"
        self.area = .init(x: 0, y: 0, width: 10, height: 10)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    @discardableResult
    public func addHoney(_ amount: Int) -> Int {
        guard honey < maximum else { return amount }
        var amount = amount
        honey.fill(amount: &amount, cap: maximum)
        return amount
    }
    
    public func removeHoney(_ amount: Int) throws {
        guard honey >= amount else { throw ContainerError.containerInsufficient }
        honey -= amount
    }
}
