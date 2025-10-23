# UIPortalView Tests

A simple demo/test app exploring `_UIPortalView`, a private iOS API that allows displaying the same view instance in multiple locations simultaneously.

## What This Is

This is a **test project** demonstrating how to wrap `_UIPortalView` for use in SwiftUI using runtime APIs to avoid static symbol references.

## What This Is NOT

This is **not** the Portal package. If you're looking for the Portal framework, go here:
**→ https://github.com/Aeastr/Portal**

## What It Shows

- Runtime obfuscation using `NSClassFromString` and KVC
- SwiftUI integration via `UIViewRepresentable`
- Proof that Source and Portal views share the same instance (same UUID, color, animations)
- Standalone SwiftUI view comparison

## Private API Warning

⚠️ This uses `_UIPortalView`, a private API. Not for App Store submission.
