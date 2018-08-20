import Foundation

func associatedValue<T>(of maybeEnum: Any) -> T? {
    let enumMirror = Mirror(reflecting: maybeEnum)
    
    guard
        enumMirror.displayStyle == .enum,
        let enumChild = enumMirror.children.first
        else { return nil }
    
    if let enumChildValue = enumChild.value as? T {
        return enumChildValue
    }
    
    let enumSubchildMirror = Mirror(reflecting: enumChild.value)
    return enumSubchildMirror.children.first?.value as? T
}

func caseName(of maybeEnum: Any) -> String {
    let enumMirror = Mirror(reflecting: maybeEnum)
    
    guard
        enumMirror.displayStyle == .enum,
        let enumChild = enumMirror.children.first
        else { return String() }
    
    return enumChild.label ?? String()
}
