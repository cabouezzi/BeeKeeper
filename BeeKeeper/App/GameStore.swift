import Foundation
import Observation

@MainActor
protocol GameRuntime: AnyObject {
    var account: Account { get }
    var apiary: Apiary { get }
    var isTutorialComplete: Bool { get }
    var onChange: (() -> Void)? { get set }
    func markSaved(at date: Date)
}

@MainActor
final class LegacyGameRuntime: GameRuntime {
    var account: Account { GameManager.shared.account }
    var apiary: Apiary { GameManager.shared.apiary }
    var isTutorialComplete: Bool { !SettingsManager.shared.isFirstLogin }
    var onChange: (() -> Void)? {
        get { GameManager.shared.onChange }
        set { GameManager.shared.onChange = newValue }
    }

    func markSaved(at date: Date) {
        apiary.lastOnline = date
    }
}

@Observable
@MainActor
final class GameStore {
    static let shared = GameStore(saveService: LocalGameSaveService.shared, runtime: LegacyGameRuntime())

    private(set) var state: GameState?
    private(set) var lastSaveError: String?

    @ObservationIgnored private let saveService: any GameSaveServicing
    @ObservationIgnored private let runtime: any GameRuntime
    @ObservationIgnored private var saveContinuation: AsyncStream<SaveRequest>.Continuation?
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    @ObservationIgnored private var debounceTask: Task<Void, Never>?
    @ObservationIgnored private var maximumDelayTask: Task<Void, Never>?
    @ObservationIgnored private var retryTask: Task<Void, Never>?
    @ObservationIgnored private var retryDelaySeconds = 1
    @ObservationIgnored private let debounce: Duration
    @ObservationIgnored private let maximumDelay: Duration

    init(
        saveService: any GameSaveServicing,
        runtime: any GameRuntime,
        debounce: Duration = .milliseconds(350),
        maximumDelay: Duration = .seconds(5)
    ) {
        self.saveService = saveService
        self.runtime = runtime
        self.debounce = debounce
        self.maximumDelay = maximumDelay
    }

    func start() throws {
        state = try snapshot()
        guard saveContinuation == nil else { return }

        let (stream, continuation) = AsyncStream.makeStream(of: SaveRequest.self)
        saveContinuation = continuation
        saveTask = Task { [weak self] in
            for await request in stream {
                guard let self else { break }
                do {
                    self.runtime.markSaved(at: .now)
                    let current = try self.snapshot()
                    self.state = current
                    try await self.saveService.saveSnapshot(current, account: self.runtime.account)
                    self.lastSaveError = nil
                    self.retryTask?.cancel()
                    self.retryTask = nil
                    self.retryDelaySeconds = 1
                    request.completion?.resume()
                } catch {
                    self.lastSaveError = error.localizedDescription
                    self.scheduleRetry()
                    request.completion?.resume(throwing: error)
                }
            }
        }

        runtime.onChange = { [weak self] in
            Task { @MainActor in self?.recordChange() }
        }
    }

    func recordChange() {
        do {
            let current = try snapshot()
            state = current
            debounceTask?.cancel()
            debounceTask = Task { [weak self] in
                guard let self else { return }
                try? await Task.sleep(for: self.debounce)
                guard !Task.isCancelled else { return }
                self.enqueueSave()
            }
            if maximumDelayTask == nil {
                maximumDelayTask = Task { [weak self] in
                    guard let self else { return }
                    try? await Task.sleep(for: self.maximumDelay)
                    guard !Task.isCancelled else { return }
                    self.enqueueSave()
                }
            }
        } catch {
            lastSaveError = error.localizedDescription
        }
    }

    func flush() async throws {
        guard let saveContinuation else { return }
        debounceTask?.cancel()
        maximumDelayTask?.cancel()
        debounceTask = nil
        maximumDelayTask = nil
        let current = try snapshot()
        state = current
        try await withCheckedThrowingContinuation { completion in
            saveContinuation.yield(SaveRequest(snapshot: current, completion: completion))
        }
    }

    private func enqueueSave() {
        debounceTask?.cancel()
        maximumDelayTask?.cancel()
        debounceTask = nil
        maximumDelayTask = nil
        guard let state else { return }
        saveContinuation?.yield(SaveRequest(snapshot: state, completion: nil))
    }

    private func scheduleRetry() {
        retryTask?.cancel()
        let delay = retryDelaySeconds
        retryDelaySeconds = min(delay * 2, 30)
        retryTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            self?.retryTask = nil
            self?.enqueueSave()
        }
    }

    private func snapshot() throws -> GameState {
        try LegacyStateAdapter.snapshot(
            account: runtime.account,
            activeApiaryID: runtime.apiary.id,
            isTutorialComplete: runtime.isTutorialComplete
        )
    }
}

private struct SaveRequest {
    let snapshot: GameState
    let completion: CheckedContinuation<Void, Error>?
}
