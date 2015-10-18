import Foundation


extension String {
  internal func contains(string: String) -> Bool {return self.rangeOfString(string) != nil}
    
    internal func floatValue() -> Float? {
        return (self as NSString).floatValue
    }
}
