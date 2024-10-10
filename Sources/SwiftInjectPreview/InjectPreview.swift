import SwiftUI

#if canImport(UIKit)
/// Creates a preview of a SwiftUI view that can be injected into a running application.
/// SwiftUI property wrappers like `@State` can be used inside the body of this macro.
/// ```swift
/// #InjectPreview {
///     Text("Hello, World!")
/// }
/// ```
/// - Tip: To make this preview work with the Xcode canvas, wrap the body of this macro in a PreviewProvider type.
/// ```swift
/// enum Previews: PreviewProvider {
///     #InjectPreview {
///         Text("Hello, World!")
///     }
/// }
/// ```
/// - Note: This macro is only available in DEBUG builds.
/// - Note: When using properties inside the body of this macro, explicitly write `return`.
@freestanding(declaration, names: named(previews), named(Previews))
public macro InjectPreview<T: View>(@ViewBuilder _ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectUIKitViewPreviewMacro")

/// Creates a preview of a UIView that can be injected into a running application.
/// ```swift
/// #InjectPreview {
///     let label = UILabel()
///     label.text = "Hello, World!"
///     return label
/// }
/// ```
/// - Tip: To make this preview work with the Xcode canvas, wrap the body of this macro in a PreviewProvider type.
/// ```swift
/// enum Previews: PreviewProvider {
///     #InjectPreview {
///         let label = UILabel()
///         label.text = "Hello, World!"
///         return label
///     }
/// }
/// ```
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration, names: named(previews), named(Previews), named(Representable))
public macro InjectPreview<T: UIView>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectUIViewPreviewMacro")

/// Creates a preview of a UIViewController that can be injected into a running application.
/// ```swift
/// #InjectPreview {
///     HelloWorldController()
/// }
/// ```
/// - Tip: To make this preview work with the Xcode canvas, wrap the body of this macro in a PreviewProvider type.
/// ```swift
/// enum Previews: PreviewProvider {
///     #InjectPreview {
///         HelloWorldController()
///     }
/// }
/// ```
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration, names: named(previews), named(Previews), named(Representable))
public macro InjectPreview<T: UIViewController>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectUIViewControllerPreviewMacro")
#endif
#if canImport(AppKit)
/// Creates a preview of a SwiftUI view that can be injected into a running application.
/// SwiftUI property wrappers like `@State` can be used inside the body of this macro.
/// ```swift
/// #InjectPreview {
///     Text("Hello, World!")
/// }
/// ```
/// - Tip: To make this preview work with the Xcode canvas, wrap the body of this macro in a PreviewProvider type.
/// ```swift
/// enum Previews: PreviewProvider {
///     #InjectPreview {
///         Text("Hello, World!")
///     }
/// }
/// ```
/// - Note: This macro is only available in DEBUG builds.
/// - Note: When using properties inside the body of this macro, explicitly write `return`
@freestanding(declaration, names: named(previews), named(Previews))
public macro InjectPreview<T: View>(@ViewBuilder _ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectAppKitViewPreviewMacro")

/// Creates a preview of a NSView that can be injected into a running application.
/// ```swift
/// #InjectPreview {
///     let text = NSText()
///     text.string = "Hello, World!"
///     return text
/// }
/// ```
/// - Tip: To make this preview work with the Xcode canvas, wrap the body of this macro in a PreviewProvider type.
/// ```swift
/// enum Previews: PreviewProvider {
///     #InjectPreview {
///         let text = NSText()
///         text.string = "Hello, World!"
///         return text
///     }
/// }
/// ```
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration, names: named(previews), named(Previews), named(Representable))
public macro InjectPreview<T: NSView>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectNSViewPreviewMacro")

/// Creates a preview of a NSViewController that can be injected into a running application.
/// ```swift
/// #InjectPreview {
///     HelloWorldController()
/// }
/// ```
/// - Tip: To make this preview work with the Xcode canvas, wrap the body of this macro in a PreviewProvider type.
/// ```swift
/// enum Previews: PreviewProvider {
///     #InjectPreview {
///         HelloWorldController()
///     }
/// }
/// ```
/// - Note: This macro is only available in DEBUG builds.
@freestanding(declaration, names: named(previews), named(Previews), named(Representable))
public macro InjectPreview<T: NSViewController>(_ body: @MainActor () -> T) = #externalMacro(module: "SwiftInjectPreviewMacro", type: "InjectNSViewControllerPreviewMacro")
#endif

enum Previews: PreviewProvider {
	#InjectPreview {
		let text = NSText()
		text.string = "Hello, World!"
		return text
	}
}
