# SwiftInjectPreview

This repository contains custom Swift macros for use with the [InjectionIII](https://github.com/johnno1962/InjectionIII) tool, allowing you to preview and inject SwiftUI views, `UIView`s, and `UIViewController`s into a running application without needing to restart the app.

## Features

- **SwiftUI View Previews**: Use the `InjectPreview` macro to display a SwiftUI view in a running application.
- **UIKit Previews**: Previews for `UIView` and `UIViewController` objects can be injected similarly, streamlining UIKit-based UI development.
- **AppKit Previews**: Previews for `NSView` and `NSViewController` objects can be injected similarly, streamlining AppKit-based UI development.
- **Debug Mode Only**: These macros are available only in DEBUG builds, ensuring they do not affect production performance.

## Usage

### SwiftUI

For SwiftUI views, the `InjectPreview` macro can be used like this:

```swift
import SwiftUI

#InjectPreview {
    Text("Hello, World!")
}
```

This will inject the view into a running application and also show it in the Xcode canvas, enabling real-time updates.

> [!TIP]
> You can use SwiftUI property wrappers like `@State` or `@Environment` inside the `InjectPreview` macro.

### UIKit / AppKit

For `UIView`/`NSView` or `UIViewController`/`NSViewController`, similar macros are available. Example usage:

```swift
#InjectPreview {
    let label = UILabel()
    label.text = "Hello, UIView!"
    return label
}
```

### XCode canvas

> [!TIP]
> To make this preview work with the Xcode canvas, wrap the body of this macro in a PreviewProvider type.
```swift
enum Previews: PreviewProvider {
    #InjectPreview {
        let text = NSText()
        text.string = "Hello, World!"
        return text
    }
}
```

## Requirements

- Swift 5.9+
- InjectionIII tool (latest version)
- These macros are limited to DEBUG builds only.

## Installation

Add this repository to your project and ensure that the `InjectionIII` tool is set up and running during development. The `@InjectPreview` macros can be used immediately in your codebase following the examples above.

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/swift-inject-preview.git", from: "1.1.0")
  ],
  targets: [
    .target(
      name: "SomeProject", 
      dependencies: [
          .product(name: "SwiftInjectPreview", package: "swift-inject-preview"),
      ]
    )
  ]
)
```
```swift
@_exported import SwiftInjectPreview
```

> [!NOTE]
> This macro does not add InjectionIII to your target. It is recommended to use [HotReloading](https://github.com/johnno1962/HotReloading) or other similar packages, or add InjectionIII to your project manually.

## Author

dankinsoid, voidilov@gmail.com

## License

SwiftInjectPreview is available under the MIT license. See the LICENSE file for more info.
