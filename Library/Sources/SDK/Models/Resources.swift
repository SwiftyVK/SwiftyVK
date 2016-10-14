import Foundation



private class ResourceTestClass {}




internal struct Resources {
  private static let pathSuffix : String = {
    #if os(OSX)
      return "-OSX"
    #elseif os(iOS)
      return "-iOS"
    #elseif os(tvOS)
      return "-tvOS"
    #elseif os(watchOS)
      return "-watchOS"
    #endif
  }()
  
  
    
  internal static let bundle : Bundle = {
    let name = "SwiftyVKResources" + pathSuffix
    let ext = "bundle"
    
    if let path = Bundle.main.path(forResource: name, ofType: ext) {
      return Bundle(path:path)!
    }
    else if let path = Bundle(for:object_getClass(ResourceTestClass())).path(forResource: name, ofType: ext) {
      return Bundle(path:path)!
    }
    
    return Bundle.main
  }()
  
    

  internal static func withSuffix(_ name : String) -> String {
    return name + pathSuffix
  }
}
