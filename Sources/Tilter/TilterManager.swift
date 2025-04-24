//
//  TilterManager.swift
//  Tilter
//
//  Created by Alfonso Tarallo on 08/04/25.
//

import CoreMotion
import CoreHaptics
import SwiftUI

@MainActor
public final class TilterManager {
    let motion = CMMotionManager()
    
    var timer: Timer? = nil
    
    var devRoll: Double = 0.0
    var devPitch: Double = 0.0
    var devYaw: Double = 0.0
    
    var isOn: Binding<Bool>
    
    public var value: Binding<Double>?
    
    public var date: Binding<Date>?
    
    public init() {
        self.isOn = Binding(get: {
            false
        }, set: { newValue in
        })
        self.value = nil
        self.date = nil
    }
    
    public init(isOn: Binding<Bool>, value: Binding<Double>) {
        self.isOn = isOn
        self.value = value
        self.date = nil
    }
    
    public init(isOn: Binding<Bool>, date: Binding<Date>) {
        self.isOn = isOn
        self.value = nil
        self.date = date
    }
    
    public init(isOn: Binding<Bool>, onTiltingLeft: (() -> Void)?, onTiltingRight: (() -> Void)?) {
        self.isOn = isOn
        self.onTiltingLeft = onTiltingLeft
        self.onTiltingRight = onTiltingRight
        
        self.value = nil
        self.date = nil
    }
    
    var gyroTask: Task<Void, Never>? = nil
    
    func startGyros() {
        guard motion.isDeviceMotionAvailable else { return }
        
        self.motion.deviceMotionUpdateInterval = 1.0 / 10.0
        self.motion.showsDeviceMovementDisplay = true
        self.motion
            .startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
        
        var referenceAttitude: CMAttitude? = nil
        var tiltingFactor: Int = 0
        
        gyroTask = Task { @MainActor in
            while isOn.wrappedValue {
                if let data = motion.deviceMotion {
                    let roll = data.attitude.roll
                    let pitch = data.attitude.pitch
                    let yaw = data.attitude.yaw

                    if referenceAttitude == nil {
                        referenceAttitude = data.attitude
                    } else {
                        let rollDifference = roll - referenceAttitude!.roll
                        
                        self.devRoll = round(rollDifference * 180.0 / .pi)
                        self.devPitch = round(pitch * 180.0 / .pi)
                        self.devYaw = round(yaw * 180.0 / .pi)
                        
                        tiltingFactor = Int((self.devRoll/100) * 10)
                        print(tiltingFactor)
                        
                        if tiltingFactor >= 1 {
                            if let onTiltingRight = onTiltingRight {
                                onTiltingRight()
                                self.playHaptic()
                            } else {
                                self.increase()
                            }
                            self.playHaptic()
                        } else if tiltingFactor <= -1 {
                            if let onTiltingLeft = onTiltingLeft {
                                onTiltingLeft()
                                self.playHaptic()
                            } else {
                                self.decrease()
                            }
                        }
                    }
                }
                
                let nanoseconds: UInt64
                
                if tiltingFactor >= 1 {
                    nanoseconds = 100_000_000/UInt64(tiltingFactor)
                } else if tiltingFactor <= -1 {
                    nanoseconds = 100_000_000/UInt64(-tiltingFactor)
                } else {
                    nanoseconds = 100_000_000
                }
                
                do {
                    try await Task.sleep(nanoseconds: nanoseconds)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    var onTiltingLeft: (() -> Void)? = nil
    var onTiltingRight: (() -> Void)? = nil
    
    func stopGyros() {
        gyroTask?.cancel()
        gyroTask = nil
        
        motion.stopDeviceMotionUpdates()
    }
    
    func increase() {
        if let _ = self.value {
            self.value!.wrappedValue = self.value!.wrappedValue + 0.1
            self.playHaptic()
        } else if let _ = self.date {
            self.date!.wrappedValue = self.date!.wrappedValue.addingTimeInterval(86400)
            self.playHaptic()
        }
    }
    
    func decrease() {
        if let _ = self.value {
            self.value!.wrappedValue = self.value!.wrappedValue - 0.1
            self.playHaptic()
        } else if let _ = self.date {
            self.date!.wrappedValue = self.date!.wrappedValue.addingTimeInterval(-86400)
            self.playHaptic()
        }
    }
    
    func playHaptic() {
        var engine: CHHapticEngine? = nil
        
        do {
            engine = try CHHapticEngine()
        } catch {
            print(error.localizedDescription)
        }
        
        guard let engine = engine else { return }
        
        engine.playsHapticsOnly = true
        
        do {
            try engine.start()
        } catch {
            print("Error starting engine: \(error)")
        }
        
        do {
            guard let path = Bundle.module.path(forResource: "provaAHAP", ofType: "json") else {
                print("AHAP file not found")
                return
            }
            let url = URL(fileURLWithPath: path)
            try engine.playPattern(from: url)
        } catch {
            print("Error playing pattern: \(error)")
        }
    }
    
}

public class TilterManagerBox: ObservableObject {
    var manager: TilterManager?
    
    public init() {}
    
    @MainActor
    public func setBindings(isOn: Binding<Bool>, value: Binding<Double>) {
        manager = TilterManager(isOn: isOn, value: value)
    }
    
    @MainActor
    public func setBindings(isOn: Binding<Bool>, date: Binding<Date>) {
        manager = TilterManager(isOn: isOn, date: date)
    }
    
    @MainActor
    public func setBindings(isOn: Binding<Bool>, onTiltingLeft: @escaping () -> Void, onTiltingRight: @escaping () -> Void) {
        manager = TilterManager(isOn: isOn, onTiltingLeft: onTiltingLeft, onTiltingRight: onTiltingRight)
    }
}
