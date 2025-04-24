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
                .onChange(of: isOn) {
                    if isOn {
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
                .onChange(of: isOn) {
                    if isOn {
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
    
    @GestureState private var isTapped: Bool = false
    
    var onTiltingLeft: (() -> Void)?
    var onTiltingRight: (() -> Void)?
    
    @StateObject private var tilterManagerBox = TilterManagerBox()
    
    func body(content: Content) -> some View {
        let tap = DragGesture(minimumDistance: 0).updating($isTapped) { (_, isTapped, _) in
            isTapped = true
        }
        
        ZStack {
            Rectangle()
                .foregroundStyle(isTapped ? .blue.opacity(0.1) : .blue.opacity(0.1))
                .frame(width: 200, height: 150)
            
            content
                .onChange(of: isOn) {
                    if isOn {
                        tilterManagerBox.manager?.startGyros()
                    } else {
                        tilterManagerBox.manager?.stopGyros()
                    }
                }
        }
        .onAppear {
            tilterManagerBox.setBindings(isOn: $isOn, onTiltingLeft: onTiltingLeft, onTiltingRight: onTiltingRight)
        }
        .gesture(tap)
        .onChange(of: isTapped) {
            if isTapped {
                isOn = true
            } else {
                isOn = false
            }
        }
        .accessibilityAddTraits(.allowsDirectInteraction)
        .accessibilityElement()
        .accessibilityLabel("Value")
        .accessibilityHint("Keep pressed and tilt the device to perform actions")
    }
}

extension View {
    
    public func tilterEnabled(isOn: Binding<Bool>, value: Binding<Double>) -> some View {
        return modifier(AccessibleSlider(isOn: isOn, value: value))
    }
    
    public func tilterEnabled(isOn: Binding<Bool>, date: Binding<Date>) -> some View {
        return modifier(AccessibleCalendar(isOn: isOn, date: date))
    }
    
    public func tilterEnabled(isOn: Binding<Bool>, onTiltingLeft: (() -> Void)?, onTiltingRight: (() -> Void)?) -> some View {
        return modifier(TiltableView(isOn: isOn, onTiltingLeft: onTiltingLeft, onTiltingRight: onTiltingRight))
    }
}
