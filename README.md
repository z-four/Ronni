
<p align="center"> 
  <img height = "215px" src="/Images/logo.jpg">
</p>

## Description

A convenient and easy to use library that will make the task of display messages simple. Message views can be displayed at the top or bottom. There are 4 different types already set up for you: Success, Error, Info, Loading, Toast, also you can create your own messages.

## Example

<p align="center">
  <img src="/Images/style.gif">
  <img src="/Images/loading.gif">
</p>

<p align="center">
  <img src="/Images/title.gif">
  <img src="/Images/custom.gif">
</p>



## Usage

##### Style:

```swift
let text = "How are you getting on?"
let style = .success //or error, info, loading, toast
let position = .top //or bottom

Ronni.show(to: navController, text: text, style: style, position: position)

// Show with custom background color
Ronni.show(to: navController, text: text, style: style, backgroundColor: UIColor.blue)

```

##### Custom message:

```swift
let message = Message()
message.title = "Captain America"
message.description = "Captain America is a fictional character appearing in American comic books"
message.backgroundColor = UIColor(hex: "4460A0")
message.image = UIImage(named: "star")
message.buttonText = "Hide"

Ronni.show(to: navController, message: message)

// Disable the auto-hiding behavior and show message from bottom
Ronni.show(to: navController, message: message, style: .success, duration: .forever, position: .bottom)

// Show with automatic duration
 Ronni.show(to: navController, message: message, style: .success, duration: .automatic, position: .top, animTime: 0.0)
```

##### Custom view:

```swift
 let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
 customView.backgroundColor = UIColor.red
              
 Ronni.show(to: navController, view: customView, duration: .forever, position: .top)
```
##### Specify one or more event listeners:
```swift
 Ronni.events.append() { event in
            switch(event) {
                case .willShow: print("Will show"); break
                case .willHide: print("Will hide"); break
                case .didShow: print("Did show"); break
                case .didHide: print("Did hide"); break
                case .didButtonClick:
                    if let navController = self.navigationController {
                        Ronni.hide(from: navController)
                    }
                break
                
                default: break
            }
        }
```
## Requirements

- CocoaPods 1.0.0+

## Installation

**Ronni** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Ronni'
```
## License

This project is licensed under the MIT license.

Copyright (c) 2017 Dmytro Zhyzhko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
