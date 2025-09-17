import Foundation

/// Represents LongPoll event. More info - https://vk.ru/dev/using_longpoll
public enum LongPollEvent {
    case forcedStop
    case historyMayBeLost
    case type1(data: Data)
    case type2(data: Data)
    case type3(data: Data)
    case type4(data: Data)
    case type5(data: Data)
    case type6(data: Data)
    case type7(data: Data)
    case type8(data: Data)
    case type9(data: Data)
    case type10(data: Data)
    case type11(data: Data)
    case type12(data: Data)
    case type13(data: Data)
    case type14(data: Data)
    case type51(data: Data)
    case type52(data: Data)
    case type61(data: Data)
    case type62(data: Data)
    case type70(data: Data)
    case type80(data: Data)
    case type114(data: Data)
    
    var data: Data? {
        return associatedValue(of: self)
    }
    
    // swiftlint:disable cyclomatic_complexity next
    init?(json: JSON) {
        guard
            let type = json.int("0"),
            let updates = (json.value as? [Any])?.dropFirst().toArray(),
            let updatesData = JSON(value: updates).data("*") else {
            return nil
        }
        
        switch type {
        case 1:
            self = .type1(data: updatesData)
        case 2:
            self = .type2(data: updatesData)
        case 3:
            self = .type3(data: updatesData)
        case 4:
            self = .type4(data: updatesData)
        case 6:
            self = .type6(data: updatesData)
        case 5:
            self = .type5(data: updatesData)
        case 7:
            self = .type7(data: updatesData)
        case 8:
            self = .type8(data: updatesData)
        case 9:
            self = .type9(data: updatesData)
        case 10:
            self = .type10(data: updatesData)
        case 11:
            self = .type11(data: updatesData)
        case 12:
            self = .type12(data: updatesData)
        case 13:
            self = .type13(data: updatesData)
        case 14:
            self = .type14(data: updatesData)
        case 51:
            self = .type51(data: updatesData)
        case 52:
            self = .type52(data: updatesData)
        case 61:
            self = .type61(data: updatesData)
        case 62:
            self = .type62(data: updatesData)
        case 70:
            self = .type70(data: updatesData)
        case 80:
            self = .type80(data: updatesData)
        case 114:
            self = .type114(data: updatesData)
        default:
            return nil
        }
    }
}
