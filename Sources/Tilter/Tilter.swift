// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct AccessibleSlider: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            content
            Text("OK")
        }
    }
}

extension Slider {
    
    public func tilterEnabled() -> some View {
        modifier(AccessibleSlider())
    }
}
