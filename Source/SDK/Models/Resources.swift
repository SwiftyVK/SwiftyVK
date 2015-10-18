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
  
  
  internal static let bundle : NSBundle = {
    let name = "SwiftyVKResources" + pathSuffix
    let ext = "bundle"
    
    if let path = NSBundle.mainBundle().pathForResource(name, ofType: ext) {
      return NSBundle(path:path)!
    }
    else if let path = NSBundle(forClass:object_getClass(ResourceTestClass())).pathForResource(name, ofType: ext) {
      return NSBundle(path:path)!
    }
    
    return NSBundle.mainBundle()
  }()
  

  internal static func withSuffix(name : String) -> String {
    return name + pathSuffix
  }
}