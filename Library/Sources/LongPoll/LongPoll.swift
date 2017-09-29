import Foundation

public protocol LongPoll {
    var isActive: Bool { get }
    
    func start(onReceiveEvents: @escaping ([LongPollEvent]) -> ())
    func stop()
}

public final class LongPollImpl: LongPoll {
    
    private weak var session: Session?
    private let operationMaker: LongPollTaskMaker
    private let connectionObserver: ConnectionObserver?
    private let getInfoDelay: TimeInterval
    
    private let synchronyQueue = DispatchQueue.global(qos: .utility)
    private let updatingQueue: OperationQueue
    
    public var isActive: Bool
    private var isConnected = false
    private var onReceiveEvents: (([LongPollEvent]) -> ())?
    
    init(
        session: Session?,
        operationMaker: LongPollTaskMaker,
        connectionObserver: ConnectionObserver?,
        getInfoDelay: TimeInterval
        ) {
        self.isActive = false
        self.session = session
        self.operationMaker = operationMaker
        self.connectionObserver = connectionObserver
        self.getInfoDelay = getInfoDelay
        
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
            guard let strongSelf = self, !strongSelf.isConnected else { return }
            strongSelf.isConnected = true

            guard strongSelf.isActive else { return }
            strongSelf.onReceiveEvents?([.connect])
            strongSelf.startUpdating()
        }
    }
    
    private func onDisconnect() {
        synchronyQueue.async { [weak self] in
            guard let strongSelf = self, strongSelf.isConnected else { return }
            strongSelf.isConnected = false
            
            guard strongSelf.isActive else { return }
            strongSelf.updatingQueue.cancelAllOperations()
            strongSelf.onReceiveEvents?([.disconnect])
        }
    }
    
    private func startUpdating() {
        getConnectionInfo { [weak self] connectionInfo in
            guard let strongSelf = self, strongSelf.isActive else { return }
            
            let data = LongPollTaskData(
                server: connectionInfo.server,
                startTs: connectionInfo.ts,
                lpKey: connectionInfo.lpKey,
                onResponse: { updates in
                    guard strongSelf.isActive == true else { return }
                    let events = updates.flatMap { LongPollEvent(json: $0) }
                    strongSelf.onReceiveEvents?(events)
                },
                onKeyExpired: {
                    strongSelf.updatingQueue.cancelAllOperations()
                    strongSelf.startUpdating()
                }
            )
            
            strongSelf.updatingQueue.cancelAllOperations()
            
            guard strongSelf.isConnected else { return }
            
            let operation = strongSelf.operationMaker.longPollTask(session: strongSelf.session, data: data)
            strongSelf.updatingQueue.addOperation(operation.toOperation())
        }
    }
    
    private func getConnectionInfo(completion: @escaping ((server: String, lpKey: String, ts: String)) -> ()) {
        guard let session = session, session.state == .authorized else { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: (server: String, lpKey: String, ts: String)?
        
        VKAPI.Messages.getLongPollServer([.useSsl: "0", .needPts: "1", .lpVersion: "2"])
            .configure(with: Config(attemptsMaxLimit: 1, handleErrors: false))
            .onSuccess { data in
                defer { semaphore.signal() }
                
                guard
                    let response = try? JSON(data: data),
                    let server = response.string("server"),
                    let lpKey = response.string("key")
                    else {
                        return
                }
                
                let ts = response.forcedString("ts")
                result = (server, lpKey, ts)
            }
            .onError { _ in
                semaphore.signal()
            }
            .send(in: session)
        
        semaphore.wait()
        
        guard let tryResult = result else {
            return synchronyQueue.asyncAfter(deadline: .now() + getInfoDelay) { [weak self] in
                self?.getConnectionInfo(completion: completion)
            }
        }
        
        completion(tryResult)
    }
    
    deinit {
        connectionObserver?.unsubscribe(object: self)
    }
}
