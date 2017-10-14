extension APIScope {
    public enum Account: APIMethod {
        case banUser(Parameters)
        case changePassword(Parameters)
        case getActiveOffers(Parameters)
        case getAppPermissions(Parameters)
        case getBanned(Parameters)
        case getCounters(Parameters)
        case getInfo(Parameters)
        case getProfileInfo(Parameters)
        case getPushSettings(Parameters)
        case registerDevice(Parameters)
        case saveProfileInfo(Parameters)
        case setNameInMenu(Parameters)
        case setOffline(Parameters)
        case setOnline(Parameters)
        case setPushSettings(Parameters)
        case setInfo(Parameters)
        case setSilenceMode(Parameters)
        case unbanUser(Parameters)
        case unregisterDevice(Parameters)
    }
}
