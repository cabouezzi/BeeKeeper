//
//  Gene.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import GameKit

enum Gene: Codable {
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
    
    case bioluminescene
    
    case royalJelly
    
    func trigger(in bee: Bee) {
        // TODO: Implement
        switch self {
        default: break
        }
    }
}
