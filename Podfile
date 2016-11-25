# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'LeanDesign' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

pod 'Fabric'
pod 'Firebase'
pod 'Firebase/Messaging’
pod 'Digits'
pod 'TwitterCore'
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'DKImagePickerController'
pod 'Swiftstraints'
pod 'Flurry-iOS-SDK/FlurrySDK'
pod 'Flurry-iOS-SDK/FlurryAds'
pod 'Crashlytics'
pod 'Caishen'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

end
