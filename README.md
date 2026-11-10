# Icro - a Micro.blog client

<img src="https://hartl.co/apps/icro/assets/images/icro-on-iphone.png" width="250">

[Icro](https://hartl.co/apps/icro/index.html) is a third-party [Micro.blog](https://micro.blog) client.

[Download from the App Store](https://itunes.apple.com/us/app/icro/id1375296597?ls=1&mt=8)

## About
Icro does not serve the purpose of a showcase project. Many parts were hacked together as I wanted to ship this App as quickly as possible.
From now on all development will happen in public on Github.
A structure with issues, planned features will be added using the GitHub tools.

## Building

Open `Icro.xcworkspace` in Xcode 27 or later and build the `Icro` scheme. Xcode resolves the Swift packages automatically.
To run on a physical device, configure signing for the app and its share extension.
Use Product → Test with the `Icro` scheme to run the unit tests.

To upload a TestFlight build, increment the build number for `Icro` and `Icro-Share`, then archive the `Icro` scheme for an iOS device with distribution signing. Upload the archive from Xcode Organizer.

## Generating Screenshots

Run `Icro` on the simulator and sign in to Micro.blog. Then run the `Screenshots` scheme on the same simulator with the test language set to English. The screenshots are saved as XCTest attachments in Xcode’s test report.

```sh
xcodebuild test -workspace Icro.xcworkspace -scheme Screenshots \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=latest' \
  -parallel-testing-enabled NO -testLanguage en CODE_SIGNING_ALLOWED=NO
```

## Contributing

Feel free to contribute to this project at any time with any improvement. In the coming days I plan to generate some issue I want to tackle for upcoming versions of Icro, some would be perfect starter tasks.

## License

Icro is free and the source code is available under MIT license. **Please do not ship this App under your own account.**
