//
//  Resources.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

public struct Resources: Codable, Equatable {
    var money: Float = 0
    var honey: Int = 0
    var pollen: Int = 0
    var beeBread: Int = 0
    
    mutating func fill(_ amount: inout Resources, cap: Resources) {
        money.fill(amount: &amount.money, cap: cap.money)
        honey.fill(amount: &amount.honey, cap: cap.honey)
        pollen.fill(amount: &amount.pollen, cap: cap.pollen)
        beeBread.fill(amount: &amount.beeBread, cap: cap.beeBread)
    }
    
    func adding(_ resources: Resources) -> Resources {
        return Resources(money: money + resources.money,
                         honey: honey + resources.honey,
                         pollen: pollen + resources.pollen,
                         beeBread: beeBread + resources.beeBread)
    }
    
    func subtracting(_ resources: Resources) -> Resources {
        return Resources(money: money - resources.money,
                         honey: honey - resources.honey,
                         pollen: pollen - resources.pollen,
                         beeBread: beeBread - resources.beeBread)
    }
    
    func canAfford(_ cost: Resources) -> Bool {
        return money >= cost.money
        && honey >= cost.honey
        && pollen >= cost.pollen
        && beeBread >= cost.beeBread
    }
    
    func isEmpty () -> Bool {
        return money <= 0
        && honey <= 0
        && pollen <= 0
        && beeBread <= 0
    }
}

internal extension AdditiveArithmetic where Self: Comparable {
    /// - Parameters:
    ///     - amount: The amount to fill.
    ///     - cap: The maximum amount the target should fill up to.
    mutating func fill(amount: inout Self, cap: Self) {
        guard self < cap else { return }
        let space = cap - self
        if space >= amount {
            self += amount
            amount = .zero
        } else {
            self += space
            amount -= space
        }
    }
}

extension Resources: CustomStringConvertible {
    public var description: String {
        var string = "Resources("
        var components = [String]()
        if money > 0 {
            components.append("money: \(money)")
        }
        if honey > 0 {
            components.append("honey: \(honey)")
        }
        if pollen > 0 {
            components.append("pollen: \(pollen)")
        }
        if beeBread > 0 {
            components.append("beeBread: \(beeBread)")
        }
        string += components.joined(separator: ", ")
        string += ")"
        return string
    }
}
