Test WIP

# Icro - a Micro.blog client

<img src="https://hartl.co/apps/icro/assets/images/icro-on-iphone.png" width="250">

[Icro](https://hartl.co/apps/icro/index.html) is a third-party [Micro.blog](https://micro.blog) client.

[Download from the App Store](https://itunes.apple.com/us/app/icro/id1375296597?ls=1&mt=8)

## About
Icro does not serve the purpose of a showcase project. Many parts were hacked together as I wanted to ship this App as quickly as possible.
From now on all development will happen in public on Github.
A structure with issues, planned features will be added using the GitHub tools.

## Building

Open `Icro.xcworkspace` in Xcode 9 and compile it. All required dependencies are checked in and can be found in the `Podfile`.
In order to fix signing, please change the development team during development.

## Generating Screenshots

To generate screenshots, go to `IcroScreenshotsTests` and modify `accessToken` constant with a valid Micro.blog access token.
Afterwards run `fastlane snapshot`.

## Contributing

Feel free to contribute to this project at any time with any improvement. In the coming days I plan to generate some issue I want to tackle for upcoming versions of Icro, some would be perfect starter tasks.

## License

Icro is free and the source code is available under MIT license. **Please do not ship this App under your own account.**
