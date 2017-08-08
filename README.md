# JESlideMenu – iOS Slide-out Menu in Swift

JESlideMenu is an easy to use slide-out menu written in Swift 3. The slide-out menu can be easily added in an existing project. The design is completely written in code with autolayout, including a hamburger/toggle button. Therefore there is no need add a toggle button, but you can if you want to.

## Requirements
- Xcode 8
- iOS 9

## Features
- completely written in Swift 3 (no bridging)
- install & adjust slide-out menu without writing any code
- premade menu design
- pan/swipe and tap gestures for opening and closing
- adjust (size/color) of the navigationbar and menu in storyboard
- supports autolayout
- supports localization
- light status bar
- menu icons
- logo/image as menu header
- dark mode
- supports: iPhone 5/6/7 & iPad

## How to install
- drag & drop the file JESlideMenu.swift (copy if needed checked)
- drag & drop new View Controller in your storyboard and select JESlideMenu for its class
- make it your initial View Controller
- give all your controllers (view controller, navigationcontroller, tab bar controller, etc.) a Storybaord ID in identity inspector
- enter the Storyboard IDs in the text fields (Menu Item 1...) in attributes inspector of JESlideMenu
- run the app

## Trouble shooting
Make sure the Storyboard IDs of your controllers match the corresponding entry in "Menu Item". If you misspell the IDs, your app will crash.