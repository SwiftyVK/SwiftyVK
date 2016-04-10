import Foundation
#if os(iOS)
  import UIKit
#endif
#if os(OSX)
  import Cocoa
#endif



private var lpQueue = dispatch_queue_create("VKLongPollQueue", DISPATCH_QUEUE_SERIAL)



private typealias VK_LongPool = VK
extension VK_LongPool {
  /**
   Long pool client. More - https://vk.com/dev/using_longpoll
   * To start and stop the server, use the start() and stop() functions
   * To check the activity of the client, use the isActive property
   * To subscribe to notifications, use NSNotificationCenter using the names of VK.LP.notifications
   */
  public struct LP {
    public private(set) static var isActive : Bool = false
    private static var observer : LPObserver?
    private static var lpKey = String()
    private static var keyIsExpired = false
    private static var server = String()
    private static var ts = String()
    
    
    ///Starting receiving updates from the long pool server
    public static func start() {
      dispatch_async(lpQueue) {
        guard VK.state == .Authorized && !isActive else {
          VK.Log.put("LongPool", "User is not authorized or LongPool is active yet")
          return}
        isActive = true
        keyIsExpired = true
        getServer()
        observer = LPObserver()
        VK.Log.put("LongPool", "Stared")
      }
    }
    
    
    
    ///Pause receiving updates from the long pool server
    public static func stop() {
      dispatch_async(lpQueue) {
        observer = nil
        isActive = false
        VK.Log.put("LongPool", "Stopped")
      }
    }
    
    
    
    private static func getServer() {
      let req = VK.API.Messages.getLongPollServer([VK.Arg.useSsl : "0", VK.Arg.needPts : "1"])
      req.catchErrors = false
      req.maxAttempts = 1
      
      req.successBlock = {(response: JSON) in
        VK.Log.put("LongPool", "get server with request \(req.id)")
        lpKey = response["key"].stringValue
        server = response["server"].stringValue
        ts = response["ts"].stringValue
        keyIsExpired = false
        update()
      }
      
      req.errorBlock = {(error: VK.Error) in
        VK.Log.put("LongPool", "Error get server with request \(req.id)")
        NSThread.sleepForTimeInterval(10)
        getServer()
      }
      VK.Log.put("LongPool", "Getting server with request \(req.id)")
      req.send()
    }
    
    
    
    private static func update() {
      dispatch_async(lpQueue) {
        guard isActive else {return}
        
        guard !keyIsExpired && !server.isEmpty && !lpKey.isEmpty && !ts.isEmpty else {
          observer?.connectionLost()
          getServer()
          return
        }
        
        let req = Request(url: "https://\(server)?act=a_check&key=\(lpKey)&ts=\(ts)&wait=25&mode=106")
        req.catchErrors = false
        req.timeout = 30
        req.maxAttempts = 1
        req.isAsynchronous = false
        req.successBlock = {(response : JSON) in
          VK.Log.put("LongPool", "Received response with request \(req.id)")
          
          ts = response["ts"].stringValue
          parse(response["updates"].array)
          
          (response["failed"].int > 0)
            ? keyIsExpired = true
            : observer?.connectionRestore()
          update()
        }
        
        req.errorBlock = {(error: VK.Error) in
          VK.Log.put("LongPool", "Received error with request \(req.id)")
          
          observer?.connectionLost()
          NSThread.sleepForTimeInterval(10)
          update()
        }
        
        VK.Log.put("LongPool", "Send with request \(req.id)")
        req.send()
      }
    }
    
    
    
    private static func parse(updates: [JSON]?) {
      guard let updates = updates else {return}
      
      var all = [JSON]()
      var updates0 = [JSON]()
      var updates1 = [JSON]()
      var updates2 = [JSON]()
      var updates3 = [JSON]()
      var updates4 = [JSON]()
      var updates6 = [JSON]()
      var updates7 = [JSON]()
      var updates8 = [JSON]()
      var updates9 = [JSON]()
      var updates51 = [JSON]()
      var updates61 = [JSON]()
      var updates62 = [JSON]()
      var updates70 = [JSON]()
      var updates80 = [JSON]()
      
      for update in updates {
        all.append(update)
        switch update[0].intValue {
        case 0:
          updates0.append(update)
        case 1:
          updates1.append(update)
        case 2:
          updates2.append(update)
        case 3:
          updates3.append(update)
        case 4:
          updates4.append(update)
        case 6:
          updates6.append(update)
        case 7:
          updates7.append(update)
        case 8:
          updates8.append(update)
        case 9:
          updates9.append(update)
        case 51:
          updates51.append(update)
        case 61:
          updates61.append(update)
        case 62:
          updates62.append(update)
        case 70:
          updates70.append(update)
        case 80:
          updates80.append(update)
        default:
          break
        }
      }
      
      !updates0.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type0, object: JSONWrapper(updates0)) : ()
      !updates1.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type1, object: JSONWrapper(updates1)) : ()
      !updates2.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type2, object: JSONWrapper(updates2)) : ()
      !updates3.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type3, object: JSONWrapper(updates3)) : ()
      !updates4.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type4, object: JSONWrapper(updates4)) : ()
      !updates6.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type6, object: JSONWrapper(updates6)) : ()
      !updates7.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type7, object: JSONWrapper(updates7)) : ()
      !updates8.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type8, object: JSONWrapper(updates8)) : ()
      !updates9.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type9, object: JSONWrapper(updates9)) : ()
      !updates51.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type51, object: JSONWrapper(updates51)) : ()
      !updates61.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type61, object: JSONWrapper(updates61)) : ()
      !updates62.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type62, object: JSONWrapper(updates62)) : ()
      !updates70.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type70, object: JSONWrapper(updates70)) : ()
      !updates80.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.type80, object: JSONWrapper(updates80)) : ()
      !all.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName(notifications.typeAll, object: JSONWrapper(all)) : ()
    }
    
    
    ///
    public enum notifications {
      ///0,$message_id,0 — delete a message with the local_id indicated
      public static let type0 = "VKLPNotificationType0"
      ///1,$message_id,$flags — replace message flags (FLAGS:=$flags)
      public static let type1 = "VKLPNotificationType1"
      ///2,$message_id,$mask[,$user_id] — install message flags (FLAGS|=$mask)
      public static let type2 = "VKLPNotificationType2"
      ///3,$message_id,$mask[,$user_id] — reset message flags (FLAGS&=~$mask)
      public static let type3 = "VKLPNotificationType3"
      ///4,$message_id,$flags,$from_id,$timestamp,$subject,$text,$attachments — add a new message
      public static let type4 = "VKLPNotificationType4"
      ///6,$peer_id,$local_id — read all incoming messages with up to $peer_id $local_id inclusive
      public static let type6 = "VKLPNotificationType6"
      ///7,$peer_id,$local_id — read all incoming messages with up to $peer_id $local_id inclusive
      public static let type7 = "VKLPNotificationType7"
      ///8,-$user_id,$extra — each $user_id has become online, $extra is not equal to 0 if the flag was handed over to mode 64, in the low byte (remainder of the division by 256) of $extra lying platform identifier
      public static let type8 = "VKLPNotificationType8"
      ///9,-$user_id,$flags — each $user_id has become offline ($flags is 0 if the user has left the site (for example, pulled out), and 1 if the offline timeout (eg, status away))
      public static let type9 = "VKLPNotificationType9"
      ///51,$chat_id,$self — one of the parameters (composition, theme) $chat_id conversations have changed. $self - whether the changes are caused by the user
      public static let type51 = "VKLPNotificationType51"
      ///61,$user_id,$flags — user $user_id began typing in the dialog. event should come again in about 5 seconds at a constant typing. $flags = 1
      public static let type61 = "VKLPNotificationType61"
      ///62,$user_id,$chat_id — user $user_id began write in the dialog $chat_id
      public static let type62 = "VKLPNotificationType62"
      ///70,$user_id,$call_id — user $user_id makes call with ID $call_id
      public static let type70 = "VKLPNotificationType70"
      ///80,$count,0 — New unread counts in the left menu has become equal to $count
      public static let type80 = "VKLPNotificationType80"
      ///List of all updates
      public static let typeAll = "VKLPNotificationTypeAll"
      ///The connection was lost
      public static let connectinDidLost = "VKLPNotificationConnectinDidLost"
      ///The connection was connected again
      public static let connectinDidRestore = "VKLPNotificationConnectinDidRestore"
    }
  }
}
//
//
//
//
//
//
//
//
//
//
///The wrapper for a variety of objects such as JSON to be compatible with NSObject. Access to the property is via an unwrap array
public class JSONWrapper {
  public let unwrap : [JSON]
  
  public init(_ value: [JSON]) {
    self.unwrap = value
  }
}
//
//
//
//
//
//
//
//
//
//
internal class LPObserver : NSObject {
  private var connected = true
  
  internal override init() {
    super.init()
    
    VK.Log.put("LongPool", "Init observer")
    
    #if os(OSX)
      NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: "connectionLostForce", name:NSWorkspaceScreensDidSleepNotification, object: nil)
      NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: "connectionRestoreForce", name:NSWorkspaceScreensDidWakeNotification, object: nil)
    #endif
    
    #if os(iOS)
      let reachability = Reachability.reachabilityForInternetConnection()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LPObserver.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LPObserver.connectionLostForce), name: UIApplicationWillResignActiveNotification, object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LPObserver.connectionRestoreForce), name:UIApplicationDidBecomeActiveNotification, object: nil)
      reachability.startNotifier()
    #endif
  }
  
  
  
  #if os(iOS)
  func reachabilityChanged(note: NSNotification) {
  let reachability = note.object as! Reachability
  reachability.isReachable() ? connectionRestore() : connectionLost()
  }
  #endif
  
  
  
  
  func connectionRestoreForce() {
    dispatch_async(lpQueue) {
      VK.LP.isActive = true
      VK.LP.update()
    }
  }
  
  
  func connectionLostForce() {
    dispatch_async(lpQueue) {
      VK.LP.isActive = false
      self.connectionLost()
    }
  }
  
  
  
  private func connectionLost() {
    
    if connected == true {
      connected = false
      VK.Log.put("LongPool", "Connection lost")
      NSNotificationCenter.defaultCenter().postNotificationName(VK.LP.notifications.connectinDidLost, object: nil)
    }
  }
  
  
  
  private func connectionRestore() {
    
    if connected == false {
      connected = true
      VK.Log.put("LongPool", "Connection restored")
      NSNotificationCenter.defaultCenter().postNotificationName(VK.LP.notifications.connectinDidRestore, object: nil)
    }
  }
  
  
  deinit {
    VK.Log.put("LongPool", "Deinit observer")
  }
}