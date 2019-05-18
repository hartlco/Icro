# AppDelegateComponent

[![Build Status](https://app.bitrise.io/app/87d51be0372e8117/status.svg?token=t9bBCCodHd1hm96MJ9nr5g)](https://app.bitrise.io/app/87d51be0372e8117)
[![Version](https://img.shields.io/cocoapods/v/AppDelegateComponent.svg?style=flat)](https://cocoapods.org/pods/AppDelegateComponent)
[![License](https://img.shields.io/cocoapods/l/AppDelegateComponent.svg?style=flat)](https://cocoapods.org/pods/AppDelegateComponent)
[![Platform](https://img.shields.io/cocoapods/p/AppDelegateComponent.svg?style=flat)](https://cocoapods.org/pods/AppDelegateComponent)

A micro-framework helping you modularize and declutter your `AppDelegate` by splitting the functionality into testable components. The components get the `AppDelegate`callbacks forwarded for implementing decoupled functionality.  
`AppDelegateComponent` consists of 3 parts:

## AppDelegateComponent
The protocol `AppDelegateComponent` defines functions from `UIApplicationDelegate`. Your types conforming to `AppDelegateComponent` can implement the callbacks it needs to provide the wanted functionality. For example registering a crash-logging framework in `func application(_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool`.

## AppDelegateComponentStore
The protocol `AppDelegateComponentStore` defines an array of `AppDelegateComponent`. They represent all available components that should receive the forwarded `AppDelegate` callbacks. One obvious candidate to conform to `AppDelegateComponentStore` is your `AppDelegate`. 

## AppDelegateComponentRunner
`AppDelegateComponentRunner` objects act as the glue between the App's `AppDelegate` and all `AppDelegateComponent` provided by the `AppDelegateComponentStore`. The runner forwards all the callbacks.

See `AppDelegate.swift` for a practical example.

This project currently only supports the most common `UIApplicationDelegate` callbacks, or what was needed for [Icro](https://github.com/hartlco/Icro). Please feel free to open a pull-request to extend it.

## Requirements

## Installation

AppDelegateComponent is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AppDelegateComponent'
```

## Author

hartlco, martin@hartl.co

## License

AppDelegateComponent is available under the MIT license. See the LICENSE file for more info.
