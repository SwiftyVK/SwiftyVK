extension _VKAPI {
  ///Methods for working with messages. More - https://vk.com/dev/messages
  public struct Market {

    ///More - https://vk.com/dev/market.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.get", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.getById
    public static func getById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.getById", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.search
    public static func search(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.search", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.getAlbums
    public static func getAlbums(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.getAlbums", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.getAlbumById
    public static func getAlbumById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.getAlbumById", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.createComment
    public static func createComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.createComment", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.getComments
    public static func getComments(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.getComments", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.deleteComment
    public static func deleteComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.deleteComment", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.restoreComment
    public static func restoreComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.restoreComment", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.editComment
    public static func editComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.editComment", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.reportComment
    public static func reportComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.reportComment", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.getCategories
    public static func getCategories(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.getCategories", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.report
    public static func report(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.report", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.add
    public static func add(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.add", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.edit
    public static func edit(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.edit", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.delete
    public static func delete(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.delete", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.restore
    public static func restore(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.restore", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.reorderItems
    public static func reorderItems(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.reorderItems", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.reorderAlbums
    public static func reorderAlbums(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.reorderAlbums", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.addAlbum
    public static func addAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.addAlbum", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.editAlbum
    public static func editAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.editAlbum", parameters: parameters)
    }

    ///More - https://vk.com/dev/messages.get
    public static func deleteAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.deleteAlbum", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.removeFromAlbum
    public static func removeFromAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.removeFromAlbum", parameters: parameters)
    }

    ///More - https://vk.com/dev/market.addToAlbum
    public static func addToAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "market.addToAlbum", parameters: parameters)
    }
  }
}
