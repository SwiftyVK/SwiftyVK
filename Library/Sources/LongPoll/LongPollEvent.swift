import Foundation

public enum LongPollEventType: Int {
    case type1 = 1
    case type2 = 2
    case type3 = 3
    case type4 = 4
    case type6 = 6
    case type7 = 7
    case type8 = 8
    case type9 = 9
    case type10 = 10
    case type11 = 11
    case type12 = 12
    case type13 = 13
    case type14 = 14
    case type51 = 51
    case type61 = 61
    case type62 = 62
    case type70 = 70
    case type80 = 80
    case type114 = 114
    case connect = 998
    case disconect = 999
}

public struct LongPollEvent {
    
    public let type: LongPollEventType
    public let update: [Any]
    
    init?(array: [Any]) {
        guard let type = (array.first as? Int).flatMap({ LongPollEventType(rawValue: $0) }) else {
            return nil
        }
        
        self.type = type
        self.update = Array(array.dropFirst())
    }
    
    init(type: LongPollEventType) {
        self.type = type
        self.update = []
    }
}
