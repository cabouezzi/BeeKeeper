//
//  SCNVector3.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/15/24.
//

import SceneKit

extension SCNVector3: AdditiveArithmetic {
    public static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        let x = lhs.x - rhs.x
        let y = lhs.y - rhs.y
        let z = lhs.z - rhs.z
        return SCNVector3(x, y, z)
    }
    
    public static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        let x = lhs.x + rhs.x
        let y = lhs.y + rhs.y
        let z = lhs.z + rhs.z
        return SCNVector3(x, y, z)
    }
    
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x
        && lhs.y == rhs.y
        && lhs.z == rhs.z
    }
    
    public static var zero: SCNVector3 {
        return SCNVector3(0, 0, 0)
    }
}

extension SCNVector3: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

extension SCNVector3 {
    static func * (lhs: SCNVector3, rhs: Float) -> SCNVector3 {
        return SCNVector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    
    static func / (lhs: SCNVector3, rhs: Float) -> SCNVector3 {
        return SCNVector3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
    
    static func *= (lhs: inout SCNVector3, rhs: Float) {
        lhs.x *= rhs
        lhs.y *= rhs
        lhs.z *= rhs
    }
    static func /= (lhs: inout SCNVector3, rhs: Float) {
        lhs.x /= rhs
        lhs.y /= rhs
        lhs.z /= rhs
    }
    
    var magnitude: Float {
        if self == .zero { return 0 }
        return sqrtf(x*x + y*y + z*z)
    }
    
    func normalized() -> SCNVector3 {
        if self == .zero { return .zero }
        return self / magnitude
    }
}
