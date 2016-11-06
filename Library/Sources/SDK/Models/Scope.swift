// swiftlint:disable cyclomatic_complexity
extension VK {
  ///Application scope
  public enum Scope: Int {
    case notify        = 1
    case friends       = 2
    case photos        = 4
    case audio         = 8
    case video         = 16
    case docs          = 131072
    case notes         = 2048
    case pages         = 128
    case status        = 1024
    case offers        = 32
    case questions     = 64
    case wall          = 8192
    case groups        = 262144
    case messages      = 4096
    case email         = 4194304
    case notifications = 524288
    case stats         = 1048576
    case ads           = 32768
    case offline       = 65536
    case market        = 134217728


    public var description: String {return Scope.toString([self])}



   public static func toInt(_ permissions: Set<Scope>) -> Int {
      var finishPerm = Int()
      for perm in permissions {finishPerm += perm.rawValue}
      return finishPerm
    }



   public static func fromInt(_ permissions: Int) -> Set<Scope> {
      var result = Set<Scope>()

      if (permissions & 1) == 1 {result.insert(.notify)}
      if (permissions & 2) == 2 {result.insert(.friends)}
      if (permissions & 4) == 4 {result.insert(.photos)}
      if (permissions & 8) == 8 {result.insert(.audio)}
      if (permissions & 16) == 16 {result.insert(.video)}
      if (permissions & 131072) == 131072 {result.insert(.docs)}
      if (permissions & 2048) == 2048 {result.insert(.notes)}
      if (permissions & 128) == 128 {result.insert(.pages)}
      if (permissions & 1024) == 1024 {result.insert(.status)}
      if (permissions & 32) == 32 {result.insert(.offers)}
      if (permissions & 64) == 64 {result.insert(.questions)}
      if (permissions & 8192) == 8192 {result.insert(.wall)}
      if (permissions & 262144) == 262144 {result.insert(.groups)}
      if (permissions & 4096) == 4096 {result.insert(.messages)}
      if (permissions & 4194304) == 4194304 {result.insert(.email)}
      if (permissions & 524288) == 524288 {result.insert(.notifications)}
      if (permissions & 1048576) == 1048576 {result.insert(.stats)}
      if (permissions & 32768) == 32768 {result.insert(.ads)}
      if (permissions & 65536) == 65536 {result.insert(.offline)}
      if (permissions & 134217728) == 134217728 {result.insert(.market)}

      return result
    }


    // swiftlint:disable switch_case_on_newline
    public static func toString(_ permissions: Set<Scope>) -> String {
      var result = String()

      for permission in permissions {
        switch permission {
        case .notify        : result += "notify,"
        case .friends       : result += "friends,"
        case .photos        : result += "photos,"
        case .audio         : result += "audio,"
        case .video         : result += "video,"
        case .docs          : result += "docs,"
        case .pages         : result += "pages,"
        case .status        : result += "status,"
        case .offers        : result += "offers,"
        case .questions     : result += "questions,"
        case .wall          : result += "wall,"
        case .groups        : result += "groups,"
        case .messages      : result += "messages,"
        case .email         : result += "email,"
        case .notifications : result += "notifications,"
        case .stats         : result += "stats,"
        case .ads           : result += "ads,"
        case .offline       : result += "offline,"
        default : break
        }
      }

      return result
    }
    // swiftlint:enable switch_case_on_newline



    public static func fromString(_ permissions: String) -> Set<Scope> {
      var result = Set<Scope>()

      if permissions.contains("notify") {result.insert(.notify)}
      if permissions.contains("friends") {result.insert(.friends)}
      if permissions.contains("photos") {result.insert(.photos)}
      if permissions.contains("audio") {result.insert(.audio)}
      if permissions.contains("video") {result.insert(.video)}
      if permissions.contains("docs") {result.insert(.docs)}
      if permissions.contains("notes") {result.insert(.notes)}
      if permissions.contains("pages") {result.insert(.pages)}
      if permissions.contains("status") {result.insert(.status)}
      if permissions.contains("questions") {result.insert(.questions)}
      if permissions.contains("wall") {result.insert(.wall)}
      if permissions.contains("groups") {result.insert(.groups)}
      if permissions.contains("messages") {result.insert(.messages)}
      if permissions.contains("email") {result.insert(.email)}
      if permissions.contains("notifications") {result.insert(.notifications)}
      if permissions.contains("stats") {result.insert(.stats)}
      if permissions.contains("ads") {result.insert(.ads)}
      if permissions.contains("notify") {result.insert(.notify)}
      if permissions.contains("offers") {result.insert(.offers)}

      return result
    }
  }
}
