class JSON: JSONContainer, CustomStringConvertible {
    
    var description: String {
        return "JSON: \(String(describing: value))"
    }
    
    let value: Any?
    
    init(data: Data?) throws {
        self.value = try JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)
    }
    
    init(value: Any?) {
        self.value = value
    }
    
    func value<T>(_ path: String) -> T? {
        let components = path.components(separatedBy: ",")
        return parsed(value: value, components: components, isRoot: true)
    }
    
    func any(_ path: String) -> Any? {
        return value(path)
    }
    
    func json(_ path: String) -> JSON {
        return .init(value: value(path))
    }
    
    func forcedData(_ path: String) -> Data {
        return data(path) ?? Data()
    }
    
    func data(_ path: String) -> Data? {
        let anyValue: Any? = value(path)
        
        guard anyValue is NSArray || anyValue is NSDictionary else {
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: anyValue as Any, options: [])
    }
    
    func forcedArray<T>(_ path: String) -> [T] {
        return array(path) ?? []
    }
    
    func array<T>(_ path: String) -> [T]? {
        return value(path)
    }
    
    func forcedDictionary<T>(_ path: String) -> [String: T] {
        return dictionary(path) ?? [:]
    }
    
    func dictionary<T>(_ path: String) -> [String: T]? {
        return value(path)
    }
    
    func forcedBool(_ path: String) -> Bool {
        return bool(path) ?? false
    }
    
    func bool(_ path: String) -> Bool? {
        return value(path)
    }
    
    func forcedString(_ path: String) -> String {
        return string(path) ?? ""
    }
    
    func string(_ path: String) -> String? {
        return value(path)
    }
    
    func forcedInt(_ path: String) -> Int {
        return int(path) ?? 0
    }
    
    func int(_ path: String) -> Int? {
        return value(path)
    }
    
    func forcedDouble(_ path: String) -> Double {
        return double(path) ?? 0
    }
    
    func double(_ path: String) -> Double? {
        return value(path)
    }
    
    func forcedFloat(_ path: String) -> Float {
        return float(path) ?? 0
    }
    
    func float(_ path: String) -> Float? {
        return value(path)
    }
}

// MARK: - Helpers
extension NSArray: JSONContainer {
    func json<T>(_ components: [String]) -> T? {
        let component = firstComponent(from: components)
        
        guard let index = Int(component), index >= 0 && index < count else {
            return nil
        }
        
        let value = object(at: index)
        return parsed(value: value, components: components)
    }
}

extension NSDictionary: JSONContainer {
    func json<T>(_ components: [String]) -> T? {
        let component = firstComponent(from: components)
        let value = object(forKey: component)
        return parsed(value: value, components: components)
    }
}

private protocol JSONContainer {}

extension JSONContainer {
    
    func makeComponents(path: String) -> [String] {
        return path.components(separatedBy: ",")
    }
    
    func firstComponent(from components: [String]) -> String {
        return components.first?.trimmingCharacters(in: .whitespaces) ?? ""
    }
    
    func parsed<T>(value: Any?, components: [String], isRoot: Bool = false) -> T? {
        var components = components
        
        if isRoot && components.first == "*" {
            return value as? T
        }
        
        if !isRoot {
            components.removeFirst()
        }
        
        if components.isEmpty {
            return value as? T
        }
        else if let array = value as? NSArray {
            return array.json(components)
        }
        else if let dict = value as? NSDictionary {
            return dict.json(components)
        }
        
        return nil
    }
}
