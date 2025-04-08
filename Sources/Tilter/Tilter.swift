// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct AccessibleSlider: ViewModifier {
    @Binding var isOn: Bool
    @Binding var value: Double
    
    var tilterManager: TilterManager {
        TilterManager(isOn: $isOn, value: $value)
    }
    
    func body(content: Content) -> some View {
        VStack {
            content
            Text("OG: \(isOn ? "On" : "Off")")
            Text("TM: \(isOn ? "On" : "Off")")
            Text("OG: \(value)")
            Text("TM: \(tilterManager.value)")
            Toggle(isOn: $isOn) {
                Text("Toggle")
            }
        }
    }
}

extension Slider {
    
    public func tilterEnabled(isOn: Binding<Bool>, value: Binding<Double>) -> some View {
        return modifier(AccessibleSlider(isOn: isOn, value: value))
    }
}
