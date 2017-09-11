import Foundation

public protocol LongPoll {
    var isActive: Bool { get }
    
    func start(onReceiveEvents: @escaping ([LongPollEvent]) -> ())
    func stop()
}

public final class LongPollImpl: LongPoll {
    
    private weak var session: Session?
    private let operationMaker: LongPollUpdatingOperationMaker
    private let connectionObserver: ConnectionObserver?
    
    private let synchronyQueue = DispatchQueue.global(qos: .utility)
    private let updatingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public var isActive: Bool
    private var isConnected = false
    private var onReceiveEvents: (([LongPollEvent]) -> ())?
    
    init(
        session: Session?,
        operationMaker: LongPollUpdatingOperationMaker,
        connectionObserver: ConnectionObserver?
        ) {
        self.isActive = false
        self.session = session
        self.operationMaker = operationMaker
        self.connectionObserver = connectionObserver
        setUpConnectionObserver()
    }
    
    public func start(onReceiveEvents: @escaping ([LongPollEvent]) -> ()) {
        synchronyQueue.sync {
            guard !isActive else { return }
            
            self.onReceiveEvents = onReceiveEvents
            isActive = true
            startUpdating()
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
        synchronyQueue.sync {
            guard !isConnected else { return }
            isConnected = true

            guard isActive else { return }
            onReceiveEvents?([.connect])
            startUpdating()
        }
    }
    
    private func onDisconnect() {
        synchronyQueue.sync {
            guard isConnected else { return }
            isConnected = false
            
            guard isActive else { return }
            updatingQueue.cancelAllOperations()
            onReceiveEvents?([.disconnect])
        }
    }
    
    private func startUpdating() {
        getConnectionInfo { [weak self] connectionInfo in
            guard let `self` = self, self.isActive else { return }
            
            let data = LongPollOperationData(
                server: connectionInfo.server,
                startTs: connectionInfo.ts,
                lpKey: connectionInfo.lpKey,
                onResponse: { updates in
                    guard self.isActive == true else { return }
                    let events = updates.flatMap { LongPollEvent(json: $0) }
                    self.onReceiveEvents?(events)
                },
                onKeyExpired: {
                    self.updatingQueue.cancelAllOperations()
                    self.startUpdating()
                }
            )
            
            self.updatingQueue.cancelAllOperations()
            
            guard self.isConnected else { return }
            
            let operation = self.operationMaker.longPollUpdatingOperation(session: self.session, data: data)
            self.updatingQueue.addOperation(operation.toOperation())
        }
    }
    
    private func getConnectionInfo(completion: @escaping ((server: String, lpKey: String, ts: String)) -> ()) {
        guard let session = session, session.state == .authorized else { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: (server: String, lpKey: String, ts: String)?
        
        VKAPI.Messages.getLongPollServer([.useSsl: "0", .needPts: "1"])
            .configure(with: Config(attemptsMaxLimit: .limited(1), handleErrors: false))
            .onSuccess { data in
                defer { semaphore.signal() }
                guard let response = try? JSON(data: data) else { return }
                guard let server = response.string("server") else { return }
                guard let lpKey = response.string("key") else { return }
                let ts = response.forcedString("ts")
                result = (server, lpKey, ts)
            }
            .onError { _ in
                semaphore.signal()
            }
            .send(in: session)
        
        semaphore.wait()
        
        guard let tryResult = result else {
            synchronyQueue.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.getConnectionInfo(completion: completion)
            }
            return
        }
        
        completion(tryResult)
    }
    
    deinit {
        connectionObserver?.unsubscribe(object: self)
    }
}
