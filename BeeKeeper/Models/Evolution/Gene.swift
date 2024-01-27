//
//  Gene.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import GameKit

enum Gene: String, Codable, CaseIterable {
    case enzymesI
    case enzymesII
    case enzymesIII
    
    case engineerI
    case engineerII
    case engineerIII
    
    case furI
    case furII
    
    case electricChargeI
    case electricChargeII
    case electricChargeIII
    
    case stripesI
    case stripesII
    case stripesIII
    
    case stingerI
    case stingerII
    case stingerIII
    
    case venomI
    case venomII
    
    case beeBread
    
    case sustainability
    
    case bioluminescence
    
    case royalJelly
    
    func trigger(in bee: Bee) {
        switch self {
        case .enzymesI:
            bee.production.honey *= 1.1
        case .enzymesII:
            bee.production.honey *= 1.11
        case .enzymesIII:
            bee.production.honey *= 1.12
            
        // TODO: Original idea was to increase honeycomb storage. What if bee is unassigned? Come up with different "power"...
        case .engineerI:
            break
        case .engineerII:
            break
        case .engineerIII:
            break
            
        case .furI:
            bee.bodyTemperature += 10
            bee.production.pollen *= 1.07
        case .furII:
            bee.bodyTemperature += 15
            bee.production.pollen *= 1.08
            
        case .electricChargeI:
            bee.production.pollen *= 1.11
        case .electricChargeII:
            bee.production.pollen *= 1.12
        case .electricChargeIII:
            bee.production.pollen *= 1.13
            
        case .stripesI:
            bee.intimidation += 10
        case .stripesII:
            bee.intimidation += 10
        case .stripesIII:
            bee.intimidation += 10
            
        case .stingerI:
            bee.stingerDamage += 10
        case .stingerII:
            bee.stingerDamage += 15
        case .stingerIII:
            bee.stingerDamage += 15
            
        case .venomI:
            bee.venomDamage += 17.5
        case .venomII:
            bee.venomDamage += 17.5
            
        case .beeBread:
            break
            
        case .sustainability:
            bee.consumption.honey *= 0.9
            
        case .bioluminescence:
            bee.intimidation += 25
            bee.venomDamage += 30
            
        case .royalJelly:
            break
            
        default: print("Gene \(self) hasn't been implemented yet")
        }
    }
    
    var texture: SKTexture {
        switch self {
        default:
            return SKTexture(imageNamed: rawValue)
        }
    }
}
