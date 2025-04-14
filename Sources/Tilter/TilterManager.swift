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
public class TilterManager {
    let motion = CMMotionManager()
    
    var timer: Timer? = nil
    
    var devRoll: Double = 0.0
    var devPitch: Double = 0.0
    var devYaw: Double = 0.0
    
    var isOn: Binding<Bool>
    
    public var value: Binding<Double>
    
    public init() {
        self.isOn = Binding(get: {
            false
        }, set: { newValue in
        })
        self.value = Binding(get: {
            0.5
        }, set: { newValue in
        })
    }
    
    public init(isOn: Binding<Bool>, value: Binding<Double>) {
        self.isOn = isOn
        self.value = value
    }
    
    var gyroTask: Task<Void, Never>? = nil
    
    func startGyros() {
        guard motion.isDeviceMotionAvailable else { return }
        
        self.motion.deviceMotionUpdateInterval = 1.0 / 10.0
        self.motion.showsDeviceMovementDisplay = true
        self.motion
            .startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
        
        var referenceAttitude: CMAttitude? = nil
        var counter = 0
        
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
                        
                        if counter == 0 {
                            if self.devRoll >= 20 && self.devRoll <= 120 {
                                self.increase(by: 0.1)
                                self.playHaptic()
                            } else if self.devRoll <= -20 && self.devRoll >= -120 || self.devRoll <= 340 && self.devRoll >= 270 {
                                self.decrease(by: 0.1)
                                self.playHaptic()
                            }
                        }
                        
                        counter = (counter + 1) % 3
                    }
                }
                
                do {
                    try await Task.sleep(nanoseconds: 100_000_000)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func stopGyros() {
        gyroTask?.cancel()
        gyroTask = nil
        
        motion.stopDeviceMotionUpdates()
    }
    
    func increase(by step: Double) {
        self.value.wrappedValue = self.value.wrappedValue + step
    }
    
    func decrease(by step: Double) {
        self.value.wrappedValue = self.value.wrappedValue - step
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
}
