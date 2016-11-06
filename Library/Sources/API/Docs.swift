extension _VKAPI {
  ///Methods for working with documents. More - https://vk.com/dev/docs
  public struct Docs {



    ///Returns detailed information about user or community documents.  More - https://vk.com/dev/docs.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.get", parameters: parameters)
    }



    ///Returns detailed information about user or community documents. More - https://vk.com/dev/docs.getById
    public static func getById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.getById", parameters: parameters)
    }



    ///Returns the server address for document upload.  More - https://vk.com/dev/docs.getUploadServer
    public static func getUploadServer(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.getUploadServer", parameters: parameters)
    }



    ///Returns the server address for document upload onto a user's or community's wall. More - https://vk.com/dev/docs.getWallUploadServer
    public static func getWallUploadServer(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.getWallUploadServer", parameters: parameters)
    }



    ///Saves a document after uploading it to a server. More - https://vk.com/dev/docs.save
    public static func save(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.save", parameters: parameters)
    }



    ///Deletes a user or community document. More - https://vk.com/dev/docs.delete
    public static func delete(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.delete", parameters: parameters)
    }



    ///Copies a document to a user's or community's document list. More - https://vk.com/dev/docs.add
    public static func add(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.add", parameters: parameters)
    }


    ///returns result of search in documents. More - https://vk.com/dev/docs.search 
    public static func search(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.search", parameters: parameters)
    }



    ///Edit a document. More - https://vk.com/dev/docs.edit
    public static func edit(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "docs.edit", parameters: parameters)
    }
  }
}
