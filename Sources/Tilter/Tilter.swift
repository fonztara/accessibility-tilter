// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct AccessibleSlider: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.red)
    }
}

extension Slider {
    
    public func tilterEnabled() -> some View {
        modifier(AccessibleSlider())
    }
}
