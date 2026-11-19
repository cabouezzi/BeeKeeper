//
//  Account.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

final class Account: Codable {
    var onChange: (() -> Void)? {
        didSet {
            bindApiaries()
            bindResearch()
        }
    }
    let id: UUID
    var name: String = "The Apiary" {
        didSet {
            NotificationCenter.default.post(name: .didChangeName, object: nil)
            onChange?()
        }
    }
    var apiaries: [Apiary] {
        didSet {
            if apiaries.isEmpty {
                apiaries = [Apiary()]
            }
            for old in oldValue where !apiaries.contains(where: { $0 === old }) {
                old.onChange = nil
            }
            bindApiaries()
            onChange?()
        }
    }
    var unlockedGenes: Set<Gene> { didSet { onChange?() } }
    var activeResearch: TimedReward<Gene>? {
        didSet {
            oldValue?.onChange = nil
            bindResearch()
            onChange?()
        }
    }

    private func bindApiaries() {
        for apiary in apiaries {
            apiary.onChange = { [weak self] in self?.onChange?() }
        }
    }

    private func bindResearch() {
        activeResearch?.onChange = { [weak self] in self?.onChange?() }
    }
    
    init() {
        id = UUID()
        apiaries = [
            Apiary()
        ]
        
        unlockedGenes = []
    }

    private enum CodingKeys: CodingKey {
        case id, name, apiaries, unlockedGenes, activeResearch, research
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        apiaries = try container.decode([Apiary].self, forKey: .apiaries)
        unlockedGenes = try container.decode(Set<Gene>.self, forKey: .unlockedGenes)
        activeResearch = try container.decodeIfPresent(TimedReward<Gene>.self, forKey: .activeResearch)
            ?? container.decodeIfPresent(TimedReward<Gene>.self, forKey: .research)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(apiaries, forKey: .apiaries)
        try container.encode(unlockedGenes, forKey: .unlockedGenes)
        try container.encodeIfPresent(activeResearch, forKey: .activeResearch)
    }
}

// TODO: One day this will move to reactive programming...
extension Notification.Name {
    static let didChangeName = Notification.Name("didChangeName")
}
