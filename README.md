# swift-module-compat-test
A set of bare-bones repro projects for https://bugs.swift.org/browse/SR-11704

## Background

In November 2019, a user reported https://bugs.swift.org/browse/SR-11704, which describes the following scenario:

- Build a binary framework in version X of Swift, where X >= 5.1
- Consume the binary framework in a project that uses version Y of Swift, where Y > X

**Expected results**: Because Swift introduced module compatibility with Swift 5.1, it is expected that projects would be able to consume binary frameworks built with earlier versions of Swift.

**Actual results**: Attempting to build the consuming project with the binary framework built using an earlier version of Swift results in a compiler error: `'QuoteList' is not a member type of 'QuoteProvider'`

## Project structure

This GitHub repo contains two projects:

- `QuoteProvider`: A module that has the `BUILD_LIBRARY_FOR_DISTRIBUTION` flag enabled, which turns on Module Compatibility. (See the "frozen" section of https://docs.swift.org/swift-book/ReferenceManual/Attributes.html). For convenience, this project also contains a `Carthage` directory that hosts binary frameworks built with Xcode 11.7/Swift 5.2.4.
- `QuoteApp`: An app that consumes the `QuoteProvider` framework as a binary artifact. For convenience, this project includes a `Framework` directory that hosts the `QuoteProvider.framework` binary dependency

## Repro steps

### Using the pre-installed binaries

- On an Intel Mac, open `QuoteApp.xcodeproj` in Xcode 12 or higher (Swift 5.3). This project already contains a copy of the binary `QuoteProvider.framework` from the QuoteProvider project, built with Xcode 11.4 (Swift 5.2.4)
- Build the project

### From scratch

- Select a version of Xcode that includes a Swift toolchain of version 5.1 or greater, but less than whatever version you're going to build your app with:
    ```bash
    sudo xcode-select --switch /Applications/Xcode_11.7.app
    ```
- Build the `QuoteProvider` project. For convenience, the `QuoteProvider` project includes a build script that invokes Carthage to do this:
    ```bash
    ./build-support/carthage-build.sh --no-skip-current
    ```

    Alternately, you can invoke `xcodebuild` directly with appropriate options.
- Move the generated `QuoteProvider.framework` into the `QuoteApp`'s "Frameworks" directory, replacing the existing QuoteProvider.framework
- Select a version of Xcode that includes a Swift toolchain of greater than whatever version you built the framework with:
    ```bash
    sudo xcode-select --switch /Applications/Xcode_12_2.app
    ```
- Open `QuoteApp.xcodeproj` in the newer version of Xcode
- Build the project

## Discussion

This is a simple repro case for the bug above. The `QuoteProvider` project declares a Swift module named "QuoteProvider". It contains two public types: a `QuoteProvider` and a `QuoteList`. One of the public methods on `QuoteProvider` returns a `QuoteList`. The module interface for this looks like:

```swift
// swift-interface-format-version: 1.0
// swift-compiler-version: Apple Swift version 5.2.4 (swiftlang-1103.0.32.9 clang-1103.0.32.53)
// swift-module-flags: -target x86_64-apple-ios9.0-simulator -enable-objc-interop -enable-library-evolution -swift-version 5 -enforce-exclusivity=checked -O -module-name QuoteProvider
import Foundation
@_exported import QuoteProvider
import Swift
@_hasMissingDesignatedInitializers public class QuoteProvider {
  public static func getQuote() -> Swift.String
  public static func getQuoteList() -> QuoteProvider.QuoteList
  @objc deinit
}
@_hasMissingDesignatedInitializers public class QuoteList {
  public func getQuoteList() -> [Swift.String]
  @objc deinit
}
```

The bug seems to result because Swift interprets the **module** `QuoteProvider` as the name of the **type** `QuoteProvider`, so the return value of `getQuoteList` is ambiguous: During compilation, Swift expects the **type** `QuoteProvider` to contain a sub-type `QuoteList`. But the module definition is actually declaring that the method is returning a `QuoteList` type from the **module** named "QuoteProvider".
