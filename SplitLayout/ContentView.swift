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
    @Binding private var orientation: SplitViewOrientation
    @Binding private var dividerThickness: Double

    @State private var dragDividerIndex: Int? = nil
    @State private var dividerOffsets: [Content.Index: CGPoint] = [:]

    public init(
        orientation: Binding<SplitViewOrientation> = .constant(.horizontal),
        dividerThickness: Binding<Double> = .constant(10),
        @SequenceBuilder content: () -> Content)
    {
        self._orientation = orientation
        self._dividerThickness = dividerThickness
        self.content = content()
    }

    public init(
        orientation: SplitViewOrientation = .horizontal,
        separatorSize: Binding<Double> = .constant(10),
        @SequenceBuilder content: () -> Content
    ) {
        self._orientation = .constant(orientation)
        self._dividerThickness = separatorSize
        self.content = content()
    }

    public var body: some View {
        Group {
            switch orientation {
            case .horizontal:
                HStack(spacing: 0) {
                    contentView
                }
                .onChange(of: dragDividerIndex) { newValue in
                    print("pstryk")
                }
            case .vertical:
                VStack(spacing: 0) {
                    contentView
                }
            }
        }
        .onChange(of: orientation) { newValue in
            dragDividerIndex = nil
            dividerOffsets = [:]
        }

    }

    private var contentView: some View {
        ForEach(sequence: content) { (index, content) in
            GeometryReader { geometry in
                switch orientation {
                case .horizontal:
                    let newWidth = geometry.size.width + dividerOffset(index: index).x - dividerOffset(index: index - 1).x
                    if newWidth.isZero || newWidth < 0 {
                        EmptyView()
                    } else {
                        content
                            .frame(width: newWidth)
                            .offset(x: dividerOffset(index: index - 1).x)
                    }
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
                        SplitDivider(orientation: $orientation)
                            .thickness(dividerThickness)
                            .offset(x: dividerOffset(index: index).x)
                    case .vertical:
                        SplitDivider(orientation: $orientation)
                            .thickness(dividerThickness)
                            .offset(y: dividerOffset(index: index).y)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            dragDividerIndex = index
                            dividerOffsets[index] = CGPoint(
                                x: value.location.x,
                                y: value.location.y
                            )
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

        var body: some View {
            Rectangle()
                .foregroundColor(Color(NSColor.separatorColor))
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
