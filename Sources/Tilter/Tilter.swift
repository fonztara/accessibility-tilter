// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct AccessibleSlider: ViewModifier {
    @Binding var isOn: Bool
    @Binding var value: Double
    
    @StateObject private var tilterManagerBox = TilterManagerBox()
    
    func body(content: Content) -> some View {
        VStack {
            content
                .onChange(of: isOn) { newValue in
                    if newValue {
                        tilterManagerBox.manager?.startGyros()
                    } else {
                        tilterManagerBox.manager?.stopGyros()
                    }
                }
        }
        .onAppear {
            tilterManagerBox.setBindings(isOn: $isOn, value: $value)
        }
    }
}

struct AccessibleCalendar: ViewModifier {
    @Binding var isOn: Bool
    @Binding var date: Date
    
    @StateObject private var tilterManagerBox = TilterManagerBox()
    
    func body(content: Content) -> some View {
        VStack {
            content
                .onChange(of: isOn) { newValue in
                    if newValue {
                        tilterManagerBox.manager?.startGyros()
                    } else {
                        tilterManagerBox.manager?.stopGyros()
                    }
                }
        }
        .onAppear {
            tilterManagerBox.setBindings(isOn: $isOn, date: $date)
        }
    }
}

struct TiltableView: ViewModifier {
    @Binding var isOn: Bool
    
    var onTiltingLeft: (() -> Void)?
    var onTiltingRight: (() -> Void)?
    
    @StateObject private var tilterManagerBox = TilterManagerBox()
    
    func body(content: Content) -> some View {
        VStack {
            content
                .onChange(of: isOn) { newValue in
                    if newValue {
                        tilterManagerBox.manager?.startGyros()
                    } else {
                        tilterManagerBox.manager?.stopGyros()
                    }
                }
        }
        .onAppear {
            tilterManagerBox.setBindings(isOn: $isOn, onTiltingLeft: onTiltingLeft, onTiltingRight: onTiltingRight)
        }
    }
}

extension View {
    
    public func tilterEnabled(isOn: Binding<Bool>, value: Binding<Double>) -> some View {
        return modifier(AccessibleSlider(isOn: isOn, value: value))
    }
    
    public func tilterEnabled(isOn: Binding<Bool>, date: Binding<Date>) -> some View {
        return modifier(AccessibleCalendar(isOn: isOn, date: date))
    }
    
    public func tilterEnabled(isOn: Binding<Bool>, onTiltingLeft: @escaping () -> Void, onTiltingRight: @escaping () -> Void) -> some View {
        return modifier(TiltableView(isOn: isOn, onTiltingLeft: onTiltingLeft, onTiltingRight: onTiltingRight))
    }
}
