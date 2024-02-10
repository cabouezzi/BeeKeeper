//
//  SFXManager.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/26/24.
//

import AVFoundation

enum SFXError: LocalizedError {
    case unknownURL
}

class SFXManager: NSObject {
    static let shared = SFXManager()
    
    enum Music {
        case evolution, birds
        
        fileprivate var filepath: String? {
            switch self {
            case .evolution:
                return Bundle.main.path(forResource: "evolution-music", ofType: "mp3")
            case .birds:
                return Bundle.main.path(forResource: "birds-loop", ofType: "wav")
            }
        }
    }
    
    enum Sounds {
        case select, pop, bubbles, bottles, failure, flute
        
        fileprivate var filepath: String? {
            switch self {
            case .select:
                return Bundle.main.path(forResource: "select", ofType: "mp3")
            case .pop:
                return Bundle.main.path(forResource: "pop-1", ofType: "mp3")
            case .bubbles:
                return Bundle.main.path(forResource: "bubbles", ofType: "mp3")
            case .bottles:
                return Bundle.main.path(forResource: "bottles", ofType: "mp3")
            case .failure:
                return Bundle.main.path(forResource: "drum", ofType: "wav")
            case .flute:
                return Bundle.main.path(forResource: "flute", ofType: "wav")
            }
        }
    }
    
    private var bag: Set<AVAudioPlayer> = []
    private var musicPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
    }
    
    private func loadSound(_ filepath: String?) throws -> AVAudioPlayer {
        guard let path = filepath else {
            throw SFXError.unknownURL
        }
        
        let url: URL
        if #available(iOS 16.0, *) {
            url = URL(filePath: path)
        } else {
            url = URL(fileURLWithPath: path)
        }
        
        let player = try AVAudioPlayer(contentsOf: url)
        player.stop()
        player.prepareToPlay()
        return player
    }
    
    func playSound(_ sound: Sounds) {
        guard let player = try? loadSound(sound.filepath) else {
            return
        }
        player.play()
        player.delegate = self
        bag.insert(player)
    }
    
    func playMusic(_ music: Music) {
        guard let plater = try? loadSound(music.filepath) else {
            return
        }
        switch music {
        case .birds:
            plater.volume = 1 / 4
        default:
            break
        }
        plater.play()
        plater.delegate = self
        plater.numberOfLoops = .max
        musicPlayer = plater
    }
    
    func stopMusic() {
        let fadeDur: TimeInterval = 0 // TODO: Fade?
        musicPlayer?.setVolume(0, fadeDuration: fadeDur)
        // Retains a reference to the player while fading out
        Task.detached { [musicPlayer] in
            guard musicPlayer != nil else { return }
            sleep(UInt32(fadeDur))
        }
        musicPlayer = nil
    }
}

extension SFXManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag {
            print("Audio play failed to play sound: \(String(describing: player.url))")
        }
        bag.remove(player)
    }
}

extension SFXManager: ModelVisitor {
    func visitBee(_ model: Bee) -> Sounds? {
        return nil
    }
    
    func visitHive(_ model: Hive) -> Sounds? {
        return .bubbles
    }
    
    func visitHoneyStorage(_ model: HoneyStorage) -> Sounds? {
        return .bubbles
    }
    
    func visitPollenStorage(_ model: PollenStorage) -> Sounds? {
        return .bottles
    }
    
    func visitIncubator(_ model: Incubator) -> Sounds? {
        return nil
    }
    
    func visitFlower(_ model: Flower) -> Sounds? {
        return nil
    }
}
