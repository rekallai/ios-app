# iOS App

## Running App Locally
### Install Dependencies
- Install the latest version of XCode
    - You might also need to install the xcode command line tools
- Install Cocoapods
    - [Sudo Less Installation](https://guides.cocoapods.org/using/getting-started.html#sudo-less-installation)
- Make sure the api is running locally
    - [Services API](<repo>/services/api)
### Set Up Project
- Install the necessary pods
    - ``pod install``
- Open workspace in XCode (``Project.xcworkspace``)
    - You will get ``pod`` issues if you open the ``.xcodeproj`` file
- Configure API endpoints and app information in Environment.swift

### Run App
- Select a simulator and run the app
    - With the 'play' button or command + r

## Issues
- Try cleaning the build in XCode
    - command + shift + k
