import Foundation

private class ResourceTestClass {}

struct Resources {
    private static let pathSuffix: String = {
        #if os(macOS)
            return "_macOS"
        #elseif os(iOS)
            return "_iOS"
        #elseif os(tvOS)
            return "_tvOS"
        #elseif os(watchOS)
            return "_watchOS"
        #endif
    }()
    
    static let bundle: Bundle = {
        let name = "SwiftyVK_resources" + pathSuffix
        let bundleType = "bundle"
        
        if
            let path = Bundle.main.path(forResource: name, ofType: bundleType),
            let bundle = Bundle(path: path) {
            return bundle
        }
        else if
            let path = Bundle(for: ResourceTestClass.self).path(forResource: name, ofType: bundleType),
            let bundle = Bundle(path: path) {
            return bundle
        }
        
        return Bundle.main
    }()
    
    static func withSuffix(_ name: String) -> String {
        return name + pathSuffix
    }
    
    static func localizedString(for key: String) -> String {
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
