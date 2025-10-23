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

        // Force layout to get proper size
        let targetSize = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        hostingController.view.frame.size = targetSize
    }

    func update(content: Content) {
        hostingController.rootView = content

        // Update size after content changes
        let targetSize = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        hostingController.view.frame.size = targetSize
    }
}

/// Wrapper for source view with proper intrinsic sizing
class SourceViewWrapper: UIView {
    let sourceView: UIView

    init(sourceView: UIView) {
        self.sourceView = sourceView
        super.init(frame: .zero)

        sourceView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sourceView)
        NSLayoutConstraint.activate([
            sourceView.topAnchor.constraint(equalTo: topAnchor),
            sourceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sourceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sourceView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        sourceView.intrinsicContentSize
    }
}

/// UIViewRepresentable that displays the source view
struct SourceViewRepresentable<Content: View>: UIViewRepresentable {
    let container: SourceViewContainer<Content>
    let content: Content

    func makeUIView(context: Context) -> SourceViewWrapper {
        SourceViewWrapper(sourceView: container.view)
    }

    func updateUIView(_ uiView: SourceViewWrapper, context: Context) {
        container.update(content: content)
        uiView.invalidateIntrinsicContentSize()
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
