extension _VKAPI {
  ///Methods for working with documents. More - https://vk.com/dev/docs
  public struct Docs {
    
    
    
    ///Returns detailed information about user or community documents.  More - https://vk.com/dev/docs.get
    public static func get(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "docs.get", parameters: parameters)
    }
    
    
    
    ///Returns detailed information about user or community documents. More - https://vk.com/dev/docs.getById
    public static func getById(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "docs.getById", parameters: parameters)
    }
    
    
    
    ///Returns the server address for document upload.  More - https://vk.com/dev/docs.getUploadServer
    public static func getUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "docs.getUploadServer", parameters: parameters)
    }
    
    
    
    ///Returns the server address for document upload onto a user's or community's wall. More - https://vk.com/dev/docs.getWallUploadServer
    public static func getWallUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "docs.getWallUploadServer", parameters: parameters)
    }
    
    
    
    ///Saves a document after uploading it to a server. More - https://vk.com/dev/docs.save
    public static func save(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "docs.save", parameters: parameters)
    }
    
    
    
    ///Deletes a user or community document. More - https://vk.com/dev/docs.delete
    public static func delete(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "docs.delete", parameters: parameters)
    }
    
    
    
    ///Copies a document to a user's or community's document list. More - https://vk.com/dev/docs.add
    public static func add(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "docs.add", parameters: parameters)
    }
    
    
    ///returns result of search in documents. More - https://vk.com/dev/docs.search 
    public static func search(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "docs.search", parameters: parameters)
    }
  }
}
