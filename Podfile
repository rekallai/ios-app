# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# ignore all warnings from all pods
inhibit_all_warnings!

def shared_pods
  pod 'Alamofire'
  pod 'AlamofireImage'
  pod 'Moya'
  pod 'Firebase/Core'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Analytics'
  pod 'JMapiOSSDK', :git => 'https://github.com/Jibestream/JMap-iOS-SDK-Pod.git'
  pod 'UIKit-iOS-Pod', :git => 'https://github.com/Jibestream/UIKit-iOS-Pod.git'
  pod 'Stripe'
  pod 'Intercom'
  pod 'JGProgressHUD'
  pod 'ContentfulRichTextRenderer'
end

target 'Project' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Project
  shared_pods

  target 'ProjectTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ProjectUITests' do
    shared_pods
  end
  
end

