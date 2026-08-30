import Foundation

public enum LongPollVersion: String {
    public static let latest = LongPollVersion.third

    case zero = "0"
    case first = "1"
    case second = "2"
    case third = "3"
}

/// Long poll client
public protocol LongPoll {
    /// Is long poll can handle events
    var isActive: Bool { get }
    
    #if compiler(>=5.5)
    /// Starts an exclusive async subscription.
    /// Long Poll can be observed by callback or stream, but not both.
    /// A second stream fails with `VKError.longPollAlreadyObserved`; cancelling or releasing stream stops Long Poll.
    @available(iOS 13.0, macOS 10.15, *)
    func eventsStream(version: LongPollVersion) -> AsyncThrowingStream<[LongPollEvent], Error>
    #endif

    /// Start recieve long poll events
    /// parameters onReceiveEvents: clousure ehich executes when long poll recieve set of events
    func start(version: LongPollVersion, onReceiveEvents: @escaping ([LongPollEvent]) -> ())
    
    /// Stops callback-based Long Poll. Does not stop an active async stream.
    func stop()
}

extension LongPoll {
    public func start(version: LongPollVersion = .latest, onReceiveEvents: @escaping ([LongPollEvent]) -> ()) {
        start(version: version, onReceiveEvents: onReceiveEvents)
    }

    #if compiler(>=5.5)
    @available(iOS 13.0, macOS 10.15, *)
    public func eventsStream(version: LongPollVersion = .latest) -> AsyncThrowingStream<[LongPollEvent], Error> {
        eventsStream(version: version)
    }
    #endif
}

public final class LongPollImpl: LongPoll {
    
    private weak var session: Session?
    private weak var operationMaker: LongPollTaskMaker?
    private let connectionObserver: ConnectionObserver?
    private let getInfoDelay: TimeInterval
    
    private let synchronyQueue = DispatchQueue.global(qos: .utility)
    private let updatingQueue: OperationQueue
    
    private let onDisconnected: (() -> ())?
    private let onConnected: (() -> ())?
    
    public var isActive: Bool
    private var isConnected = false
    private var isStreamOpen = false
    private var onReceiveEvents: (([LongPollEvent]) -> ())?
    private var taskData: LongPollTaskData?
    private var version: LongPollVersion = .first
    
    init(
        session: Session?,
        operationMaker: LongPollTaskMaker,
        connectionObserver: ConnectionObserver?,
        getInfoDelay: TimeInterval,
        onConnected: (() -> ())? = nil,
        onDisconnected: (() -> ())? = nil
        ) {
        self.isActive = false
        self.session = session
        self.operationMaker = operationMaker
        self.connectionObserver = connectionObserver
        self.getInfoDelay = getInfoDelay
        self.onConnected = onConnected
        self.onDisconnected = onDisconnected

        self.updatingQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            return queue
        }()
    }

    #if compiler(>=5.5)
    @available(iOS 13.0, macOS 10.15, *)
    public func eventsStream(version: LongPollVersion) -> AsyncThrowingStream<[LongPollEvent], Error> {
        AsyncThrowingStream { continuation in
        do {
            try startStreamIfNotStarted(
                    version: version,
                    onReceiveEvents: { continuation.yield($0) }
                )
            }
            catch {
                return continuation.finish(throwing: error)
            }

            continuation.onTermination = { [weak self] _ in
                self?.stop(ignoringStream: true)
            }
        }
    }
    #endif
    
    public func start(version: LongPollVersion, onReceiveEvents: @escaping ([LongPollEvent]) -> ()) {
        synchronyQueue.sync {
            guard !isActive else { return }
            
            self.version = version
            self.onReceiveEvents = onReceiveEvents
            isActive = true
            setUpConnectionObserver()
        }
    }
    
    public func stop() {
        stop(ignoringStream: false)
    }

    private func stop(ignoringStream: Bool) {
        synchronyQueue.sync {
            guard isActive else { return }
            guard ignoringStream || !isStreamOpen else { return }
            
            isStreamOpen = false
            isActive = false
            updatingQueue.cancelAllOperations()
        }
    }

    private func startStreamIfNotStarted(
        version: LongPollVersion,
        onReceiveEvents: @escaping ([LongPollEvent]) -> ()
    ) throws {
        try synchronyQueue.sync {
            guard !isActive, !isStreamOpen else { throw VKError.longPollAlreadyObserved }

            self.version = version
            self.onReceiveEvents = onReceiveEvents
            isActive = true
            isStreamOpen = true
            setUpConnectionObserver()
        }
    }
    
    private func setUpConnectionObserver() {
        connectionObserver?.subscribe(
            object: self,
            callbacks: (
                onConnect: { [weak self] in
                    self?.onConnect()
                },
                onDisconnect: { [ weak self] in
                    self?.onDisconnect()
                }
        ))
    }
    
    private func onConnect() {
        synchronyQueue.async { [weak self] in
            guard
                let strongSelf = self,
                !strongSelf.isConnected
                else { return }
            
            strongSelf.isConnected = true

            guard strongSelf.isActive else { return }
            strongSelf.onConnected?()
            
            if strongSelf.taskData != nil {
                strongSelf.startUpdating()
            }
            else {
                strongSelf.updateTaskDataAndStartUpdating()
            }
        }
    }
    
    private func onDisconnect() {
        synchronyQueue.async { [weak self] in
            guard
                let strongSelf = self,
                strongSelf.isConnected
                else { return }
            
            strongSelf.isConnected = false
            
            guard strongSelf.isActive else { return }
            strongSelf.updatingQueue.cancelAllOperations()
            strongSelf.onDisconnected?()
        }
    }
    
    private func updateTaskDataAndStartUpdating() {
        getConnectionInfo { [weak self] connectionInfo in
            guard self?.isActive == true else { return }
            
            self?.taskData = LongPollTaskData(
                server: connectionInfo.server,
                startTs: connectionInfo.ts,
                lpKey: connectionInfo.lpKey,
                onResponse: { updates in
                    guard self?.isActive == true else { return }
                    let events = updates.compactMap { LongPollEvent(json: $0) }
                    self?.onReceiveEvents?(events)
                },
                onError: { self?.handleError($0) }
            )
            
            self?.startUpdating()
        }
    }
    
    private func startUpdating() {
        updatingQueue.cancelAllOperations()
        
        guard
            isConnected,
            let data = taskData
            else { return }
        
        guard let operation = operationMaker?.longPollTask(session: session, data: data) else { return }
        updatingQueue.addOperation(operation.toOperation())
    }
    
    private func getConnectionInfo(completion: @escaping ((server: String, lpKey: String, ts: String)) -> ()) {
        guard
            let session = session,
            session.state == .authorized
            else { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: (server: String, lpKey: String, ts: String)?
        
        APIScope.Messages.getLongPollServer([
            .useSsl: "0",
            .needPts: "1",
            .lpVersion: version.rawValue
            ])
            .configure(with: Config(attemptsMaxLimit: 1, handleErrors: false))
            .onSuccess { data in
                defer { semaphore.signal() }
                
                guard
                    let response = try? JSON(data: data),
                    let server = response.string("server"),
                    let lpKey = response.string("key")
                    else { return }
                
                let ts = response.int("ts")?.toString() ?? response.forcedString("ts")
                result = (server, lpKey, ts)
            }
            .onError { _ in
                semaphore.signal()
            }
            .send(in: session)
        
        semaphore.wait()
        
        guard let unwrappedResult = result else {
            return synchronyQueue.asyncAfter(deadline: .now() + getInfoDelay) { [weak self] in
                self?.getConnectionInfo(completion: completion)
            }
        }
        
        completion(unwrappedResult)
    }
    
    private func handleError(_ error: LongPollTaskError) {
        switch error {
        case .unknown:
            onReceiveEvents?([.forcedStop])
        case .historyMayBeLost:
            onReceiveEvents?([.historyMayBeLost])
        case .connectionInfoLost:
            updateTaskDataAndStartUpdating()
        }
    }
    
    deinit {
        connectionObserver?.unsubscribe(object: self)
    }
}
