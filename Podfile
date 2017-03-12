# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'LinDesign' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

pod 'Flurry-iOS-SDK'
pod 'Firebase'
pod 'Crashlytics'
pod 'Firebase/Messaging’
pod 'Digits'
pod 'TwitterCore'
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'DKImagePickerController'
pod 'Swiftstraints'
pod 'Alamofire', '~> 4.0'
pod 'AlamofireImage', '~> 3.1'
pod 'SWXMLHash', '~> 3.0.0'
pod 'CryptoSwift', :git => "https://github.com/krzyzanowskim/CryptoSwift", :branch => "master"
pod 'Cosmos', '~> 7.0'
pod 'Toast-Swift', '~> 2.0.0'
pod 'EFCountingLabel', '~> 1.0.0'
pod 'Socket.IO-Client-Swift', '~> 8.2.0' # Or latest version



post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

end
