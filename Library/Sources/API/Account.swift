public extension VK.Api {
    public enum Account: APIMethod {
        case getCounters(Parameters)
        case setNameInMenu(Parameters)
        case setOnline(Parameters)
        case setOffline(Parameters)
        case lookupContacts(Parameters)
        case registerDevice(Parameters)
        case unregisterDevice(Parameters)
        case setSilenceMode(Parameters)
        case getPushSettings(Parameters)
        case setPushSettings(Parameters)
        case getAppPermissions(Parameters)
        case getActiveOffers(Parameters)
        case banUser(Parameters)
        case unbanUser(Parameters)
        case getBanned(Parameters)
        case getInfo(Parameters)
        case setInfo(Parameters)
        case changePassword(Parameters)
        case getProfileInfo(Parameters)
        case saveProfileInfo(Parameters)
    }
}
