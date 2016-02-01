extension _VKAPI {
  ///Methods for working with VK database. More - https://vk.com/dev/database
  public struct Database {
    
    
    
    ///Returns a list of countries. More - https://vk.com/dev/database.getCountries
    public static func getCountries(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getCountries", parameters: parameters)
    }
    
    
    
    ///Returns a list of regions. More - https://vk.com/dev/database.getRegions
    public static func getRegions(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getRegions", parameters: parameters)
    }
    
    
    
    ///Returns information about streets by their IDs. More - https://vk.com/dev/database.getStreetsById
    public static func getStreetsById(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getStreetsById", parameters: parameters)
    }
    
    
    
    ///Returns information about countries by their IDs. More - https://vk.com/dev/database.getCountriesById
    public static func getCountriesById(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getCountriesById", parameters: parameters)
    }
    
    
    
    ///Returns a list of cities. More - https://vk.com/dev/database.getCities
    public static func getCities(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getCities", parameters: parameters)
    }
    
    
    
    ///Returns information about cities by their IDs. More - https://vk.com/dev/database.getCitiesById
    public static func getCitiesById(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getCitiesById", parameters: parameters)
    }
    
    
    
    ///Returns a list of higher education institutions. More - https://vk.com/dev/database.getUniversities
    public static func getUniversities(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getUniversities", parameters: parameters)
    }
    
    
    
    ///Returns a list of schools школ. More - https://vk.com/dev/database.getSchools
    public static func getSchools(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getSchools", parameters: parameters)
    }
    
    
    
    ///This is an open method; it does not require an access_token. More - https://vk.com/dev/database.getSchoolClasses
    public static func getSchoolClasses(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getSchoolClasses", parameters: parameters)
    }
    
    
    
    ///Returns a list of faculties (i.e., university departments). More - https://vk.com/dev/database.getFaculties
    public static func getFaculties(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getFaculties", parameters: parameters)
    }
    
    
    
    ///Returns list of chairs on a specified faculty. More - https://vk.com/dev/database.getChairs
    public static func getChairs(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "database.getChairs", parameters: parameters)
    }
  }
}
