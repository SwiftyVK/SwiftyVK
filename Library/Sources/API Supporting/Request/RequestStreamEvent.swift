import Foundation

#if compiler(>=5.5)
@available(iOS 13.0, macOS 10.15, *)
public enum RequestStreamEvent {
    case progress(ProgressType)
    case response(Data)
}
#endif
