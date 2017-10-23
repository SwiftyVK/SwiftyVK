protocol IDGenerator {
    func next() -> Int64
}

final class IDGeneratorImpl: IDGenerator {
    let queue = DispatchQueue(label: "")
    var id: Int64 = 0
    
    func next() -> Int64 {
        return queue.sync {
            id += 1
            return id
        }
    }
}
