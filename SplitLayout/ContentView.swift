//
//  ContentView.swift
//  SplitLayout
//
//  Created by Marcin Krzyzanowski on 23/07/2022.
//

import SwiftUI
import SequenceBuilder

public struct SplitView<Content: Collection>: View  where Content.Element: View, Content.Index == Int {

    private let content: Content
    private let dividerColor: Color
    private let dividerThickness: Double
    @Binding private var orientation: SplitViewOrientation

    @State private var dividerOffsets: [Content.Index: CGPoint] = [:]
    @State private var sizes: [Content.Index: CGSize] = [:]

    public init(
        orientation: Binding<SplitViewOrientation> = .constant(.horizontal),
        dividerColor: Color = Color(NSColor.separatorColor),
        dividerThickness: Double = 10,
        @SequenceBuilder content: () -> Content)
    {
        self._orientation = orientation
        self.dividerThickness = dividerThickness
        self.dividerColor = dividerColor
        self.content = content()
    }

    public init(
        orientation: SplitViewOrientation = .horizontal,
        dividerColor: Color = Color(NSColor.separatorColor),
        dividerThickness: Double = 10,
        @SequenceBuilder content: () -> Content
    ) {
        self._orientation = .constant(orientation)
        self.dividerThickness = dividerThickness
        self.dividerColor = dividerColor
        self.content = content()
    }

    public var body: some View {
        Group {
            switch orientation {
            case .horizontal:
                HStack(spacing: 0) {
                    contentView
                }
            case .vertical:
                VStack(spacing: 0) {
                    contentView
                }
            }
        }
        .onChange(of: orientation) { newValue in
            dividerOffsets = [:]
        }

    }

    private var contentView: some View {
        ForEach(sequence: content) { (index, content) in
            GeometryReader { geometry in
                switch orientation {
                case .horizontal:
                    Group {
                        let newWidth = geometry.size.width + dividerOffset(index: index).x - dividerOffset(index: index - 1).x
                        if newWidth.isZero || newWidth < 0 {
                            EmptyView()
                        } else {
                            content
                                .frame(width: max(0, newWidth))
                                .offset(x: dividerOffset(index: index - 1).x)
                        }
                    }
                    .background(GeometryReader { geometry in
                        // Track the overallSize using a GeometryReader on the ZStack that contains the
                        // primary, secondary, and splitter
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: geometry.size)
                            .onPreferenceChange(SizePreferenceKey.self) {
                                sizes[index] = $0
                            }
                    })
                case .vertical:
                    let newHeight = geometry.size.height + dividerOffset(index: index).y - dividerOffset(index: index - 1).y
                    if newHeight.isZero || newHeight < 0 {
                        EmptyView()
                    } else {
                        content
                            .frame(height: newHeight)
                            .offset(y: dividerOffset(index: index - 1).y)
                    }
                }
            }

            if index != self.content.count - 1 { // not last
                Group {
                    switch orientation {
                    case .horizontal:
                        SplitDivider(
                            orientation: $orientation,
                            color: dividerColor
                        )
                        .thickness(dividerThickness)
                        .offset(x: dividerOffset(index: index).x)
                    case .vertical:
                        SplitDivider(
                            orientation: $orientation,
                            color: dividerColor
                        )
                        .thickness(dividerThickness)
                        .offset(y: dividerOffset(index: index).y)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dividerOffsets[index] = CGPoint(
                                x: value.location.x,
                                y: value.location.y
                            )
                        }
                        .onEnded { _ in

                        }
                )
            }
        }
    }

    private func dividerOffset(index: Int) -> CGPoint {
        dividerOffsets[index] ?? .zero
    }

    private struct SplitDivider: View {
        @Binding var orientation: SplitViewOrientation
        let color: Color

        var body: some View {
            Rectangle()
                .foregroundColor(color)
        }

        func thickness(_ value: Double) -> some View {
            switch orientation {
            case .horizontal:
                return self.frame(width: value)
            case .vertical:
                return self.frame(height: value)
            }
        }
    }
}

public enum SplitViewOrientation {
    case vertical
    case horizontal

    public mutating func toggle() {
        switch self {
        case .vertical:
            self = .horizontal
        case .horizontal:
            self = .vertical
        }
    }
}

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ContentView: View {
    @State var orientation1: SplitViewOrientation = .horizontal
    @State var orientation2: SplitViewOrientation = .vertical
    @State var orientation3: SplitViewOrientation = .vertical

    var body: some View {
        SplitView(orientation: $orientation1) {
            EditorContent()
            EditorContent()
            SplitView(orientation: $orientation2) {
                EditorContent()
                EditorContent()
                EditorContent()
                EditorContent()
                EditorContent()
            }
            .onTapGesture {
                orientation2.toggle()
            }
            EditorContent()
            EditorContent()
            EditorContent()
            SplitView(orientation: $orientation3) {
                EditorContent()
                EditorContent()
                EditorContent()
                EditorContent()
                EditorContent()
            }
            .onTapGesture {
                orientation3.toggle()
            }
        }
        .onTapGesture {
            orientation1.toggle()
        }
    }
}

struct EditorContent: View {
    @State var color: Color = .Pastel.random(.oklab)

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
                .onTapGesture {
                    color = .Pastel.random(.oklab)
                }

            HStack {
                Text("Lorem ipsum")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
