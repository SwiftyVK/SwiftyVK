extension VK {
  ///Application scope
  public enum  Scope : Int {
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

    
    
   public static func toInt(_ permissions : [Scope]) -> Int {
      var finishPerm = Int()
      for perm in permissions {finishPerm += perm.rawValue}
      return finishPerm
    }
    
    
    
   public static func fromInt(_ permissions : Int) -> [Scope] {
      var array = [Scope]()
      
      permissions.byteSwapped
      if (permissions & 1) == 1                 {array.append(Scope.notify)}
      if (permissions & 2) == 2                 {array.append(Scope.friends)}
      if (permissions & 4) == 4                 {array.append(Scope.photos)}
      if (permissions & 8) == 8                 {array.append(Scope.audio)}
      if (permissions & 16) == 16               {array.append(Scope.video)}
      if (permissions & 131072) == 131072       {array.append(Scope.docs)}
      if (permissions & 2048) == 2048           {array.append(Scope.notes)}
      if (permissions & 128) == 128             {array.append(Scope.pages)}
      if (permissions & 1024) == 1024           {array.append(Scope.status)}
      if (permissions & 32) == 32               {array.append(Scope.offers)}
      if (permissions & 64) == 64               {array.append(Scope.questions)}
      if (permissions & 8192) == 8192           {array.append(Scope.wall)}
      if (permissions & 262144) == 262144       {array.append(Scope.groups)}
      if (permissions & 4096) == 4096           {array.append(Scope.messages)}
      if (permissions & 4194304) == 4194304     {array.append(Scope.email)}
      if (permissions & 524288) == 524288       {array.append(Scope.notifications)}
      if (permissions & 1048576) == 1048576     {array.append(Scope.stats)}
      if (permissions & 32768) == 32768         {array.append(Scope.ads)}
      if (permissions & 65536) == 65536         {array.append(Scope.offline)}
      if (permissions & 134217728) == 134217728 {array.append(Scope.market)}
    
      return array
    }
    
    
    
    public static func toString(_ permissions: [Scope]) -> String {
      var string = String()
      
      for permission in permissions {
        switch permission {
        case Scope.notify        : string += "notify,"
        case Scope.friends       : string += "friends,"
        case Scope.photos        : string += "photos,"
        case Scope.audio         : string += "audio,"
        case Scope.video         : string += "video,"
        case Scope.docs          : string += "docs,"
        case Scope.pages         : string += "pages,"
        case Scope.status        : string += "status,"
        case Scope.offers        : string += "offers,"
        case Scope.questions     : string += "questions,"
        case Scope.wall          : string += "wall,"
        case Scope.groups        : string += "groups,"
        case Scope.messages      : string += "messages,"
        case Scope.email         : string += "email,"
        case Scope.notifications : string += "notifications,"
        case Scope.stats         : string += "stats,"
        case Scope.ads           : string += "ads,"
        case Scope.offline       : string += "offline,"
        default : break
        }
      }
      
      return string
    }
    
    
    
    public static func fromString(_ permissions: String) -> [Scope] {
      var array = [Scope]()
      
      if permissions.contains("notify") {array.append(Scope.notify)}
      if permissions.contains("friends") {array.append(Scope.friends)}
      if permissions.contains("photos") {array.append(Scope.photos)}
      if permissions.contains("audio") {array.append(Scope.audio)}
      if permissions.contains("video") {array.append(Scope.video)}
      if permissions.contains("docs") {array.append(Scope.docs)}
      if permissions.contains("notes") {array.append(Scope.notes)}
      if permissions.contains("pages") {array.append(Scope.pages)}
      if permissions.contains("status") {array.append(Scope.status)}
      if permissions.contains("questions") {array.append(Scope.questions)}
      if permissions.contains("wall") {array.append(Scope.wall)}
      if permissions.contains("groups") {array.append(Scope.groups)}
      if permissions.contains("messages") {array.append(Scope.messages)}
      if permissions.contains("email") {array.append(Scope.email)}
      if permissions.contains("notifications") {array.append(Scope.notifications)}
      if permissions.contains("stats") {array.append(Scope.stats)}
      if permissions.contains("ads") {array.append(Scope.ads)}
      if permissions.contains("notify") {array.append(Scope.notify)}
      if permissions.contains("offers") {array.append(Scope.offers)}
      
      return array
    }
  }
}
