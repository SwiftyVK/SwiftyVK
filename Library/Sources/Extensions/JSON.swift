class JSON: JSONContainer {
    let value: Any?
    
    init(data: Data?) {
        guard let data = data else {
            self.value = nil
            return
        }
        
        guard let value = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            self.value = nil
            return
        }
        
        self.value = value
    }
    
    subscript<T>(_ path: String) -> T? {
        let components = path.components(separatedBy: ",")
        return parsed(value: value, components: components, isRoot: true)
    }
    
    subscript(_ path: String) -> Data {
        let anyValue: Any? = self[path]
        
        guard anyValue is NSArray || anyValue is NSDictionary else {
            return Data()
        }
        
        return (try? JSONSerialization.data(withJSONObject: anyValue as Any, options: .prettyPrinted)) ?? Data()
    }
    
    subscript<T>(_ path: String) -> Array<T> {
        return self[path] ?? []
    }
    
    subscript<T>(_ path: String) -> Dictionary<String, T> {
        return self[path] ?? [:]
    }
    
    subscript(_ path: String) -> Bool {
        return self[path] ?? false
    }
    
    subscript(_ path: String) -> String {
        return self[path] ?? ""
    }
    
    subscript(_ path: String) -> Int {
        return self[path] ?? 0
    }
    
    subscript(_ path: String) -> Double {
        return self[path] ?? 0
    }
    
    subscript(_ path: String) -> Float {
        return self[path] ?? 0
    }
}

// MARK: - Helpers
extension NSArray: JSONContainer {
    func json<T>(_ components: [String]) -> T? {
        let component = firstComponent(from: components)
        
        guard let index = Int(component) else {
            return nil
        }
        
        guard index >= 0 && index < count else {
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
        
        if !isRoot {
            components.removeFirst()
        }
        
        if components.isEmpty {
            return value as? T
        } else if let array = value as? NSArray {
            return array.json(components)
        } else if let dict = value as? NSDictionary {
            return dict.json(components)
        } else if isRoot && components.first == "*" {
            return value as? T
        }
        
        return nil
    }
}
