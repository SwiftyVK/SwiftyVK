extension _VKAPI {
  ///Methods for working with VK database. More - https://vk.com/dev/database
  public struct Database {
    
    
    
    ///Returns a list of countries. More - https://vk.com/dev/database.getCountries
    public static func getCountries(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getCountries", parameters: parameters)
    }
    
    
    
    ///Returns a list of regions. More - https://vk.com/dev/database.getRegions
    public static func getRegions(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getRegions", parameters: parameters)
    }
    
    
    
    ///Returns information about streets by their IDs. More - https://vk.com/dev/database.getStreetsById
    public static func getStreetsById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getStreetsById", parameters: parameters)
    }
    
    
    
    ///Returns information about countries by their IDs. More - https://vk.com/dev/database.getCountriesById
    public static func getCountriesById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getCountriesById", parameters: parameters)
    }
    
    
    
    ///Returns a list of cities. More - https://vk.com/dev/database.getCities
    public static func getCities(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getCities", parameters: parameters)
    }
    
    
    
    ///Returns information about cities by their IDs. More - https://vk.com/dev/database.getCitiesById
    public static func getCitiesById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getCitiesById", parameters: parameters)
    }
    
    
    
    ///Returns a list of higher education institutions. More - https://vk.com/dev/database.getUniversities
    public static func getUniversities(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getUniversities", parameters: parameters)
    }
    
    
    
    ///Returns a list of schools школ. More - https://vk.com/dev/database.getSchools
    public static func getSchools(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getSchools", parameters: parameters)
    }
    
    
    
    ///This is an open method; it does not require an access_token. More - https://vk.com/dev/database.getSchoolClasses
    public static func getSchoolClasses(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getSchoolClasses", parameters: parameters)
    }
    
    
    
    ///Returns a list of faculties (i.e., university departments). More - https://vk.com/dev/database.getFaculties
    public static func getFaculties(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getFaculties", parameters: parameters)
    }
    
    
    
    ///Returns list of chairs on a specified faculty. More - https://vk.com/dev/database.getChairs
    public static func getChairs(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "database.getChairs", parameters: parameters)
    }
  }
}
