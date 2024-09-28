import SwiftUI

/// Creates a preview of a SwiftUI view that can be injected into a running application and displayed in the Xcode canvas as well.
/// SwiftUI property wrappers like `@State` can be used inside the body of this macro.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: View>(@ViewBuilder _ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectViewPreviewMacro")

#if canImport(UIKit)
/// Creates a preview of a UIView that can be injected into a running application and displayed in the Xcode canvas as well.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: UIView>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectUIViewPreviewMacro")

/// Creates a preview of a UIViewController that can be injected into a running application and displayed in the Xcode canvas as well.
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration)
public macro InjectPreview<T: UIViewController>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectUIViewControllerPreviewMacro")
#endif
