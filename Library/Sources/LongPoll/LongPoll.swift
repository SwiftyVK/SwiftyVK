import Foundation

/// Long poll client
public protocol LongPoll {
    /// Is long poll can handle events
    var isActive: Bool { get }
    
    /// Start recieve long poll events
    /// parameters onReceiveEvents: clousure ehich executes when long poll recieve set of events
    func start(onReceiveEvents: @escaping ([LongPollEvent]) -> ())
    
    /// Stop recieve long poll events
    func stop()
}

public final class LongPollImpl: LongPoll {
    
    private weak var session: Session?
    private let operationMaker: LongPollTaskMaker
    private let connectionObserver: ConnectionObserver?
    private let getInfoDelay: TimeInterval
    
    private let synchronyQueue = DispatchQueue.global(qos: .utility)
    private let updatingQueue: OperationQueue
    
    private let onDisconnected: (() -> ())?
    private let onConnected: (() -> ())?
    
    public var isActive: Bool
    private var isConnected = false
    private var onReceiveEvents: (([LongPollEvent]) -> ())?
    private var taskData: LongPollTaskData?
    
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
    
    public func start(onReceiveEvents: @escaping ([LongPollEvent]) -> ()) {
        synchronyQueue.sync {
            guard !isActive else { return }
            
            self.onReceiveEvents = onReceiveEvents
            isActive = true
            setUpConnectionObserver()
        }
    }
    
    public func stop() {
        synchronyQueue.sync {
            guard isActive else { return }
            
            isActive = false
            updatingQueue.cancelAllOperations()
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
                    let events = updates.flatMap { LongPollEvent(json: $0) }
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
        
        let operation = operationMaker.longPollTask(session: session, data: data)
        updatingQueue.addOperation(operation.toOperation())
    }
    
    private func getConnectionInfo(completion: @escaping ((server: String, lpKey: String, ts: String)) -> ()) {
        guard
            let session = session,
            session.state == .authorized
            else { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: (server: String, lpKey: String, ts: String)?
        
        APIScope.Messages.getLongPollServer([.useSsl: "0", .needPts: "1", .lpVersion: "2"])
            .configure(with: Config(attemptsMaxLimit: 1, handleErrors: false))
            .onSuccess { data in
                defer { semaphore.signal() }
                
                guard
                    let response = try? JSON(data: data),
                    let server = response.string("server"),
                    let lpKey = response.string("key")
                    else { return }
                
                let ts = response.forcedString("ts")
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
