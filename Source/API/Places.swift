extension _VKAPI {
  ///Methods for working with geolocation. More - https://vk.com/dev/places
  public struct Places {
    
    
    
    ///Adds a new location to the location database. More - https://vk.com/dev/places.add
    public static func add(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "places.add", parameters: parameters)
    }
    
    
    
    ///Returns information about locations by their IDs. More - https://vk.com/dev/places.getById
    public static func getById(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "places.getById", parameters: parameters)
    }
    
    
    
    ///Returns a list of locations that match the search criteria. More - https://vk.com/dev/places.search
    public static func search(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "places.search", parameters: parameters)
    }
    
    
    
    ///Checks a user in at the specified location. More - https://vk.com/dev/places.checkin
    public static func checkin(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "places.checkin", parameters: parameters)
    }
    
    
    
    ///Returns a list of user check-ins at locations according to the set parameters. More - https://vk.com/dev/places.getCheckins
    public static func getCheckins(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "places.getCheckins", parameters: parameters)
    }
    
    
    
    ///Returns a list of all types of locations. More - https://vk.com/dev/places.getTypes
    public static func getTypes(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "places.getTypes", parameters: parameters)
    }
  }
}