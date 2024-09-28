import SwiftUI

#if canImport(UIKit)
/// Creates a preview of a SwiftUI view that can be injected into a running application.
/// SwiftUI property wrappers like `@State` can be used inside the body of this macro.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: View>(@ViewBuilder _ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectUIKitViewPreviewMacro")

/// Creates a preview of a UIView that can be injected into a running application.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: UIView>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectUIViewPreviewMacro")

/// Creates a preview of a UIViewController that can be injected into a running application.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: UIViewController>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectUIViewControllerPreviewMacro")
#endif
#if canImport(AppKit)
/// Creates a preview of a SwiftUI view that can be injected into a running application.
/// SwiftUI property wrappers like `@State` can be used inside the body of this macro.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: View>(@ViewBuilder _ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectAppKitViewPreviewMacro")

/// Creates a preview of a NSView that can be injected into a running application.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: NSView>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectNSViewPreviewMacro")

/// Creates a preview of a NSViewController that can be injected into a running application.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: NSViewController>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectNSViewControllerPreviewMacro")
#endif
