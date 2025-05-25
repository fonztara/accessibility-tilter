# Tilter

**Tilter** is a lightweight Swift package that enables tilt-based interactions on iPhone. With Tilter, you can trigger actions or control values by tilting the device left or right — perfect for building more natural and accessible user interfaces in SwiftUI.

## Features

- 📱 Detect left and right tilting of the iPhone  
- 🎚 Bind tilt input to sliders and numeric values  
- 📅 Adjust dates using tilt gestures  
- ⚙️ Customize tilt behaviors with your own logic  
- 🧩 Easy integration with SwiftUI

## Installation

Tilter is available via Swift Package Manager.

1. Open your project in Xcode.  
2. Go to **File > Add Packages…**  
3. Enter the URL of the repository:

   ```
   https://github.com/yourusername/Tilter.git
   ```

4. Select the version and add the package to your project.

## Usage

Import the package:

```swift
import Tilter
```

### Tilt-Controlled Slider

```swift
@State var isOn = false
@State var value = 0.5

Slider(value: $value)
    .tilterEnabled(isOn: $isOn, value: $value)
```

### Tilt to Change Date

```swift
@State var isOn = false
@State var date = Date()

Text(date.formatted(date: .numeric, time: .omitted))
    .tilterEnabled(isOn: $isOn, date: $date)
```

### Custom Tilt Actions

```swift
@State var isOn = false
@State var number = 0

Text("\(number)")
    .tilterEnabled(isOn: $isOn,
                   onTiltingLeft: { number -= 1 },
                   onTiltingRight: { number += 1 })
```

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE. See the [LICENSE](./LICENSE) file for details.
