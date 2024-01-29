//
//  Resources.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import Foundation
import UIKit

struct Resources: Codable, Equatable {
    var money: Float = 0
    var honey: Float = 0
    var pollen: Float = 0
    var beeBread: Float = 0
    
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
    
    /// - Parameters:
    ///     - font: The font to use
    ///     - delimiter: A unicode string. Example "\n" in unicode becomes "\u{0085}"
    ///     - verbose: Whether to include costs that are not greater than 0. 
    func attributedString(font: UIFont = .preferredFont(forTextStyle: .body), delimiter: String = "\t", verbose: Bool = false, roundDecimals: Bool = false) -> NSAttributedString {
        func attachment(_ name: String) -> NSAttributedString {
            guard let image = UIImage(named: name) else { return NSAttributedString(string: "") }
            let attachment = NSTextAttachment()
            let scale = image.size.width / image.size.height
            attachment.bounds.size = .init(width: font.lineHeight * scale, height: font.lineHeight)
            attachment.bounds.origin.y = (font.capHeight.rounded() - font.lineHeight) / 2
            attachment.image = image
            let holder = NSMutableAttributedString(string: "\u{00a0}")
            holder.append(NSAttributedString(attachment: attachment))
            return NSAttributedString(attributedString: holder)
        }
        
        let decimals = NumberFormatStyleConfiguration.Precision.fractionLength(0...(roundDecimals ? 0 : 2))
        let text = NSMutableAttributedString(string: "", attributes: [.font: font])
        if money > 0 || verbose {
            text.append(NSAttributedString(string: money.formatted(.number.precision(decimals))))
            text.append(attachment("honeySymbol"))
            text.append(NSAttributedString(string: delimiter))
        }
        if honey > 0 || verbose {
            text.append(NSAttributedString(string: honey.formatted(.number.precision(decimals))))
            text.append(attachment("honeySymbol"))
            text.append(NSAttributedString(string: delimiter))
        }
        if pollen > 0 || verbose {
            text.append(NSAttributedString(string: pollen.formatted(.number.precision(decimals))))
            text.append(attachment("pollenSymbol"))
            text.append(NSAttributedString(string: delimiter))
        }
        if beeBread > 0 || verbose {
            text.append(NSAttributedString(string: beeBread.formatted(.number.precision(decimals))))
            text.append(attachment("honeySymbol"))
            text.append(NSAttributedString(string: delimiter))
        }
        return text
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
    var description: String {
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
