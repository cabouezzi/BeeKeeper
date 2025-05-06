//
//  SFXManager.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/26/24.
//

import AVFoundation
import Combine

enum SFXError: LocalizedError {
    case unknownURL
}

class SFXManager: NSObject {
    static let shared = SFXManager()
    
    enum Music {
        case evolution, birds, childish
        
        fileprivate var filepath: String? {
            switch self {
            case .evolution:
                return Bundle.main.path(forResource: "evolution-music", ofType: "mp3")
            case .birds:
                return Bundle.main.path(forResource: "birds-loop", ofType: "wav")
            case .childish:
                return Bundle.main.path(forResource: "childish-music", ofType: "mp3")
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
    
    class MusicLooper: NSObject, AVAudioPlayerDelegate {
        var separationInterval: TimeInterval = 0
        var samples: [AVAudioPlayer] = []
        
        private var currentPlayer: AVAudioPlayer?
        private var lastPlayer: AVAudioPlayer?
        
        override init() {
            super.init()
        }
        
        init(separationInterval: TimeInterval, samples: [AVAudioPlayer]) {
            self.separationInterval = separationInterval
            self.samples = samples
        }
        
        func stop() {
            currentPlayer?.stop()
        }
        
        func next() {
            if let currentPlayer = currentPlayer {
                lastPlayer = currentPlayer
                currentPlayer.stop()
            }
            guard let player = getRandomPlayer() else { return }
            let volume = player.volume
            player.volume = 0
            player.delegate = self
            player.play()
            player.setVolume(volume, fadeDuration: 20)
            currentPlayer = player
        }
        
        private func getRandomPlayer() -> AVAudioPlayer? {
            guard samples.count > 1 else { return samples.first }
            return samples.filter({ $0 !== lastPlayer }).randomElement()
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            currentPlayer = nil
            lastPlayer = player
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(Int(separationInterval)))) { [weak self] in
                guard let self = self else { return }
                next()
            }
        }
    }
    
    private var bag = Set<AVAudioPlayer>()
    private var musicPlayer: AVAudioPlayer?
    
    private let looper = MusicLooper()
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        // Subscribe to music‐volume changes
        SettingsManager.shared.$musicVolume.publisher
            .sink { [weak self] newVolume in
                self?.musicPlayer?.volume = newVolume
                self?.looper.samples.forEach({ $0.volume = newVolume })
            }
            .store(in: &cancellables)
        
        // Subscribe to SFX‐volume changes
        SettingsManager.shared.$soundEffectsVolume.publisher
            .sink { [weak self] newVolume in
                self?.bag.forEach { $0.volume = newVolume }
            }
            .store(in: &cancellables)
    }
    
    func apiaryAmbience() {
        playMusic(.birds)
    }
    
    private func loadPlayer(_ filepath: String?) throws -> AVAudioPlayer {
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
    
    func playerForSound(_ sound: Sounds) -> AVAudioPlayer? {
        return try? loadPlayer(sound.filepath)
    }
    
    func playSound(_ sound: Sounds) {
        guard let player = try? loadPlayer(sound.filepath) else { return }
        player.volume = SettingsManager.shared.soundEffectsVolume
        player.play()
        player.delegate = self
        bag.insert(player)
    }
    
    func playerForMusic(_ music: Music) -> AVAudioPlayer? {
        return try? loadPlayer(music.filepath)
    }
    
    func playMusic(_ music: Music) {
        guard SettingsManager.shared.musicVolume > 0,
              let player = try? loadPlayer(music.filepath)
        else { return }
        
        player.volume = SettingsManager.shared.musicVolume
        
        switch music {
        case .birds:
            player.volume /= 2
            looper.samples = [playerForMusic(.childish)].compactMap({ $0 })
            looper.samples.forEach({ $0.volume = player.volume * 2 })
            looper.separationInterval = 60
            looper.next()
        default:
            break
        }
        player.play()
        player.delegate = self
        player.numberOfLoops = .max
        musicPlayer = player
    }
    
    func stopMusic() {
        looper.stop()
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
            print("Audio player failed to play sound: \(String(describing: player.url))")
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
