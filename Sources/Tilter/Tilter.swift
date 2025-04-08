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
                .padding()
            Text("OG: \(isOn ? "On" : "Off")")
            Text("OG: \(value)")
                .padding(.bottom, 32)
            Text("TM: \(tilterManager.isOn.wrappedValue ? "On" : "Off")")
            Text("TM: \(tilterManager.value.wrappedValue.description)")
                .padding(.bottom, 32)
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
