import Foundation
#if os(iOS)
  import UIKit
#endif
#if os(OSX)
  import Cocoa
#endif



private var longPollQueue = dispatch_queue_create("VKLongPollQueue", DISPATCH_QUEUE_SERIAL)


private typealias VK_LongPool = VK
extension VK_LongPool {
  /**
   Long pool client. More - https://vk.com/dev/using_longpoll
   * To start and stop the server, use the start() and stop() functions
   * To check the activity of the client, use the isActive property
   * To subscribe to notifications, use NSNotificationCenter using the names of VK.LP.notifications
   */
  public class LP {
    public private(set) static var isActive : Bool = false
    private static var instance : VK.LP!
    private var observer : LPObserver
    private var lpKey = String()
    private var keyIsExpired = false
    private var server = String()
    private var ts = String()
    private var connected = true
    private var lpSemaphore = dispatch_semaphore_create(1)
    
    
    
    ///Starting receiving updates from the long pool server
    public class func start() {
      if VK.state == .Authorized {
        dispatch_async(longPollQueue, {
          if VK.LP.instance == nil {
            VK.LP.instance = LP()
          }
          
          if self.isActive == false {
            self.isActive = true
            VK.LP.instance?.keyIsExpired = true
            VK.LP.instance?.getServer()
          }
          Log([.longPool], "longPool: stared")
          
        })
      }
    }
    
    
    
    ///Pause receiving updates from the long pool server
    public class func pause() {
      isActive = false
    }
    
    
    
    ///Stopping and removing long pool client
    public class func stop() {
      pause()
      instance = nil
    }
    
    
    
    internal init() {
      observer = LPObserver()
    }
    
    
    
    private func getServer() {
      let req = VK.API.Messages.getLongPollServer([VK.Arg.useSsl : "0", VK.Arg.needPts : "1"])
      req.catchErrors = false
      req.maxAttempts = 1
      
      req.successBlock = {(response: JSON) in
        Log([.longPool], "longPool: get server")
        self.lpKey = response["key"].stringValue
        self.server = response["server"].stringValue
        self.ts = response["ts"].stringValue
        
        if self.keyIsExpired {
          self.keyIsExpired = false
          self.update()
        }
      }
      
      req.errorBlock = {(error: VK.Error) in
        Log([.longPool], "LongPool: Error get server")
        NSThread.sleepForTimeInterval(10)
        self.getServer()
      }
      req.send()
    }
    
    
    
    internal func update() {
      if VK.LP.isActive {
        dispatch_async(longPollQueue, {
          dispatch_semaphore_wait(self.lpSemaphore, DISPATCH_TIME_FOREVER)
          
          let req = Request(url: "https://\(self.server)?act=a_check&key=\(self.lpKey)&ts=\(self.ts)&wait=25&mode=106")
          req.catchErrors = false
          req.timeout = 30
          req.maxAttempts = 1
          req.successBlock = {(response : JSON) in
            Log([.longPool], "longPool: received response")
            
            if response["failed"].int > 0 {
              self.keyIsExpired = true
              self.getServer()
            }
            else {
              self.ts = response["ts"].stringValue
              self.parse(response["updates"].arrayValue)
              self.observer.connectionRestore()
              self.update()
            }
            dispatch_semaphore_signal(self.lpSemaphore)
          }
          
          req.errorBlock = {(error: VK.Error) in
            Log([.longPool], "longPool: received error")
            
            self.observer.connectionLost()
            NSThread.sleepForTimeInterval(10)
            self.update()
            dispatch_semaphore_signal(self.lpSemaphore)
          }
          
          Log([.longPool], "longPool: send")
          req.send()
        })
      }
    }
    
    
    
    private func parse(updates: [JSON]) {
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
      !all.isEmpty ? NSNotificationCenter.defaultCenter().postNotificationName("VKLPAll", object: JSONWrapper(all)) : ()
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
      public static let connectinDidLost = "VKLPNotificationConnectinDidRestore"
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
  
  internal override init() {
    super.init()
    
    #if os(OSX)
      NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: "connectionLostForce", name:NSWorkspaceScreensDidSleepNotification, object: nil)
      NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: "connectionRestoreForce", name:NSWorkspaceScreensDidWakeNotification, object: nil)
    #endif
    
    #if os(iOS)
      let reachability = Reachability.reachabilityForInternetConnection()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectionLostForce", name: UIApplicationWillResignActiveNotification, object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectionRestoreForce", name:UIApplicationDidBecomeActiveNotification, object: nil)
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
    VK.LP.start()
    connectionRestore()
  }
  
  
  func connectionLostForce() {
    VK.LP.stop()
    connectionLost()
  }
  
  
  
  func connectionLost() {
    if VK.LP.instance?.connected == true {
      VK.LP.instance.connected = false
      Log([.longPool], "longPool: connection lost")
      NSNotificationCenter.defaultCenter().postNotificationName(VK.LP.notifications.connectinDidLost, object: nil)
    }
  }
  
  
  
  func connectionRestore() {
    if VK.LP.isActive == true && VK.LP.instance.connected == false {
      VK.LP.instance.connected = true
      Log([.longPool], "longPool: connection restored")
      NSNotificationCenter.defaultCenter().postNotificationName(VK.LP.notifications.connectinDidRestore, object: nil)
    }
  }
}