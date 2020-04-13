# Uncomment the next line to define a global platform for your project

# ignore all warnings from all pods
inhibit_all_warnings!

def shared_pods
  pod 'Alamofire'
  pod 'AlamofireImage'
  pod 'Moya'
  pod 'Firebase/Core'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'JGProgressHUD'
end

target 'Project' do
  platform :ios, '12.0'

  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Project
  shared_pods
  pod 'Analytics'

  target 'ProjectTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ProjectUITests' do
    shared_pods
  end
  
end

target 'ProjectTV' do
  platform :tvos, '12.0'
  use_frameworks!
  shared_pods
end
