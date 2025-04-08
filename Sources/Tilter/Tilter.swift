// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct AccessibleSlider: ViewModifier {
    @Binding var value: Double
    
    func body(content: Content) -> some View {
        content
            .onChange(of: value) { newValue in
                print(newValue)
            }
    }
}

extension Slider {
    
    public func tilterEnabled(value: Binding<Double>) -> some View {
        return modifier(AccessibleSlider(value: value))
    }
}
