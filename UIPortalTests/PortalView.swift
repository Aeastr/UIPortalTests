//
//  PortalView.swift
//  UIPortalTests
//
//  Runtime wrapper for private _UIPortalView API
//

import SwiftUI
import UIKit

// MARK: - Runtime Wrapper for _UIPortalView

/// A wrapper around the private _UIPortalView class using runtime APIs
class PortalViewWrapper: UIView {
    private var portalView: UIView?

    var sourceView: UIView? {
        didSet {
            updateSourceView()
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        sourceView?.intrinsicContentSize ?? CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    var hidesSourceView: Bool = false {
        didSet {
            portalView?.setValue(hidesSourceView, forKey: "hidesSourceView")
        }
    }

    var matchesAlpha: Bool = true {
        didSet {
            portalView?.setValue(matchesAlpha, forKey: "matchesAlpha")
        }
    }

    var matchesTransform: Bool = true {
        didSet {
            portalView?.setValue(matchesTransform, forKey: "matchesTransform")
        }
    }

    var matchesPosition: Bool = true {
        didSet {
            portalView?.setValue(matchesPosition, forKey: "matchesPosition")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPortalView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPortalView()
    }

    private func setupPortalView() {
        // Access _UIPortalView via runtime
        guard let portalClass = NSClassFromString("_UIPortalView") as? UIView.Type else {
            print("⚠️ _UIPortalView class not available")
            return
        }

        let portal = portalClass.init(frame: bounds)
        portal.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(portal)
        self.portalView = portal

        // Set default properties
        portal.setValue(true, forKey: "matchesAlpha")
        portal.setValue(true, forKey: "matchesTransform")
        portal.setValue(true, forKey: "matchesPosition")
    }

    private func updateSourceView() {
        portalView?.setValue(sourceView, forKey: "sourceView")
    }
}

// MARK: - UIViewRepresentable Wrapper

/// UIViewRepresentable wrapper for the portal view
struct PortalViewRepresentable: UIViewRepresentable {
    let sourceView: UIView
    var hidesSourceView: Bool = false
    var matchesAlpha: Bool = true
    var matchesTransform: Bool = true
    var matchesPosition: Bool = true

    func makeUIView(context: Context) -> PortalViewWrapper {
        let portal = PortalViewWrapper()
        portal.sourceView = sourceView
        portal.hidesSourceView = hidesSourceView
        portal.matchesAlpha = matchesAlpha
        portal.matchesTransform = matchesTransform
        portal.matchesPosition = matchesPosition
        return portal
    }

    func updateUIView(_ uiView: PortalViewWrapper, context: Context) {
        uiView.sourceView = sourceView
        uiView.hidesSourceView = hidesSourceView
        uiView.matchesAlpha = matchesAlpha
        uiView.matchesTransform = matchesTransform
        uiView.matchesPosition = matchesPosition
    }
}

// MARK: - Source View Container

/// Container that holds a SwiftUI view in a UIHostingController
/// and exposes the UIView for portaling
class SourceViewContainer<Content: View> {
    let hostingController: UIHostingController<Content>

    var view: UIView {
        hostingController.view
    }

    init(content: Content) {
        self.hostingController = UIHostingController(rootView: content)
        self.hostingController.view.backgroundColor = .clear
        self.hostingController.sizingOptions = .intrinsicContentSize
    }

    func update(content: Content) {
        hostingController.rootView = content
    }
}

/// UIViewControllerRepresentable that displays the source view
struct SourceViewRepresentable<Content: View>: UIViewControllerRepresentable {
    let container: SourceViewContainer<Content>
    let content: Content

    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let controller = container.hostingController
        controller.view.setContentHuggingPriority(.required, for: .horizontal)
        controller.view.setContentHuggingPriority(.required, for: .vertical)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        container.update(content: content)
        uiViewController.view.invalidateIntrinsicContentSize()
    }
}

// MARK: - Portal View Helper

/// Creates a portal of a UIView from a SourceViewContainer
struct PortalView<Content: View>: View {
    let source: SourceViewContainer<Content>
    var hidesSource: Bool = false
    var matchesAlpha: Bool = true
    var matchesTransform: Bool = true
    var matchesPosition: Bool = true

    var body: some View {
        PortalViewRepresentable(
            sourceView: source.view,
            hidesSourceView: hidesSource,
            matchesAlpha: matchesAlpha,
            matchesTransform: matchesTransform,
            matchesPosition: matchesPosition
        )
    }
}
