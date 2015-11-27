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
    
    
    
    public var description: String {return Scope.toString([self])}

    
    
   public static func toInt(permissions : [Scope]) -> Int {
      var finishPerm = Int()
      for perm in permissions {finishPerm += perm.rawValue}
      return finishPerm
    }
    
    
    
   public static func fromInt(permissions : Int) -> [Scope] {
      var array = [Scope]()
      
      permissions.byteSwapped
      if (permissions & 1) == 1               {array.append(Scope.notify)}
      if (permissions & 2) == 2               {array.append(Scope.friends)}
      if (permissions & 4) == 4               {array.append(Scope.photos)}
      if (permissions & 8) == 8               {array.append(Scope.audio)}
      if (permissions & 16) == 16             {array.append(Scope.video)}
      if (permissions & 131072) == 131072     {array.append(Scope.docs)}
      if (permissions & 2048) == 2048         {array.append(Scope.notes)}
      if (permissions & 128) == 128           {array.append(Scope.pages)}
      if (permissions & 1024) == 1024         {array.append(Scope.status)}
      if (permissions & 32) == 32             {array.append(Scope.offers)}
      if (permissions & 64) == 64             {array.append(Scope.questions)}
      if (permissions & 8192) == 8192         {array.append(Scope.wall)}
      if (permissions & 262144) == 262144     {array.append(Scope.groups)}
      if (permissions & 4096) == 4096         {array.append(Scope.messages)}
      if (permissions & 4194304) == 4194304   {array.append(Scope.email)}
      if (permissions & 524288) == 524288     {array.append(Scope.notifications)}
      if (permissions & 1048576) == 1048576   {array.append(Scope.stats)}
      if (permissions & 32768) == 32768       {array.append(Scope.ads)}
      if (permissions & 65536) == 65536       {array.append(Scope.offline)}
      
      return array
    }
    
    
    
    public static func toString(permissions: [Scope]) -> String {
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
    
    
    
    public static func fromString(permissions: String) -> [Scope] {
      var array = [Scope]()
      
      if permissions.containsString("notify") {array.append(Scope.notify)}
      if permissions.containsString("friends") {array.append(Scope.friends)}
      if permissions.containsString("photos") {array.append(Scope.photos)}
      if permissions.containsString("audio") {array.append(Scope.audio)}
      if permissions.containsString("video") {array.append(Scope.video)}
      if permissions.containsString("docs") {array.append(Scope.docs)}
      if permissions.containsString("notes") {array.append(Scope.notes)}
      if permissions.containsString("pages") {array.append(Scope.pages)}
      if permissions.containsString("status") {array.append(Scope.status)}
      if permissions.containsString("questions") {array.append(Scope.questions)}
      if permissions.containsString("wall") {array.append(Scope.wall)}
      if permissions.containsString("groups") {array.append(Scope.groups)}
      if permissions.containsString("messages") {array.append(Scope.messages)}
      if permissions.containsString("email") {array.append(Scope.email)}
      if permissions.containsString("notifications") {array.append(Scope.notifications)}
      if permissions.containsString("stats") {array.append(Scope.stats)}
      if permissions.containsString("ads") {array.append(Scope.ads)}
      if permissions.containsString("notify") {array.append(Scope.notify)}
      if permissions.containsString("offers") {array.append(Scope.offers)}
      
      return array
    }
  }
}
