#if canImport(UIKit)
    import UIKit

    public typealias PlatformImage = UIImage
#endif

#if canImport(AppKit)
    import AppKit

    public typealias PlatformImage = NSImage
#endif
