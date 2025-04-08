// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct AccessibleSlider: ViewModifier {
    @Binding var isOn: Bool
    @Binding var value: Double
    
    @StateObject private var tilterManagerBox = TilterManagerBox()
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                tilterManagerBox.setBindings(isOn: $isOn, value: $value)
            }
            .onChange(of: isOn) { newValue in
                tilterManagerBox.setBindings(isOn: $isOn, value: $value)
            }
    }
}

extension View {
    
    public func tilterEnabled(isOn: Binding<Bool>, value: Binding<Double>) -> some View {
        return modifier(AccessibleSlider(isOn: isOn, value: value))
    }
}
