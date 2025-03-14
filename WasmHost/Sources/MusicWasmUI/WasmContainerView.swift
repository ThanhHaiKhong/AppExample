//
//  WasmContainerView.swift
//  app
//
//  Created by L7Studio on 10/2/25.
//
import AsyncWasm
import OSLog
import SwiftUI
import WasmSwiftProtobuf

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
public struct WasmContainerView<ContentView: View>: View {
    @Bindable var engine: WasmEngine
    @ViewBuilder var contentView: (EngineVersion) -> ContentView
    @Environment(\.wasmBuilder) var builder
    public enum Mode { case manual, automatic}
    let mode: Mode
    public init(engine: WasmEngine,
                mode: Mode = .automatic,
                contentView: @escaping (EngineVersion) -> ContentView) {
        self.engine = engine
        self.mode = mode
        self.contentView = contentView
    }
    public var body: some View {
        VStack {
            switch engine.state {
            case .stopped, .starting:
                ProgressView()
            case let .updating(val):
                ProgressView(value: val) {
                    Text("Downloading ...")
                }
                .progressViewStyle(.linear)
                .padding()
            case let .reload(ver):
                ProgressView() {
                    Text("Reloading \(ver.name)...")
                }
                .padding()
            case let .running(version):
                contentView(version)
            case .releasing:
                EmptyView()
            case let .failed(error):
                ScrollView {
                    VStack {
                        Text(error.localizedDescription)
                            .font(.body)
                            .padding()
                        Button("Retry") {
                            
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .task {
            do {
                try await self.engine.load(with: builder)
            } catch {
                self.engine.state = .failed(error)
            }
        }
    }

}
