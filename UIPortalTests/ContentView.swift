//
//  ContentView.swift
//  UIPortalTests
//
//  Created by Aether on 10/23/25.
//

import SwiftUI

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var sourceContainer: SourceViewContainer<AnyView>?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        animatedContent
                            .fixedSize()
                        Spacer()
                    }
                } header: {
                    Text("Standalone SwiftUI View")
                } footer: {
                    Text("New instance created each render")
                }

                Section {
                    HStack {
                        Spacer()
                        if let container = sourceContainer {
                            SourceViewRepresentable(
                                container: container,
                                content: AnyView(animatedContent)
                            )
                            .fixedSize()
                        }
                        Spacer()
                    }
                } header: {
                    Text("Source View")
                } footer: {
                    Text("UIHostingController - the real view instance")
                }

                Section {
                    HStack {
                        Spacer()
                        if let container = sourceContainer {
                            PortalView(
                                source: container,
                                hidesSource: false,
                                matchesPosition: false
                            )
                            .fixedSize()
                        }
                        Spacer()
                    }
                } header: {
                    Text("Portal View")
                } footer: {
                    Text("_UIPortalView showing the same instance")
                }
            }
            .navigationTitle("UIPortalView Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        withAnimation(.spring(response: 0.6)) {
                            rotation += 45
                        }
                    } label: {
                        Label("Rotate", systemImage: "rotate.right")
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.6)) {
                            scale = scale == 1.0 ? 1.5 : 1.0
                        }
                    } label: {
                        Label("Scale", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                }
            }
        }
        .onAppear {
            if sourceContainer == nil {
                sourceContainer = SourceViewContainer(content: AnyView(animatedContent))
            }
        }
    }

    var animatedContent: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .font(.system(size: 50))
                .foregroundStyle(.tint)
            Text("\(UUID())")
                .font(.caption)
                .monospaced()
                .fontWeight(.semibold)
        }
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        
    }
}

#Preview {
    ContentView()
}
