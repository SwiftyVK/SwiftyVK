import Foundation

extension String {
    
    static func random(_ length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let randomIndex = Int.random(in: 0 ..< letters.length)
            var nextChar = letters.character(at: randomIndex)
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
