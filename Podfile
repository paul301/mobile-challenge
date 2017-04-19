# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PxChallenge' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PxChallenge
  pod 'Moya/RxSwift'
  pod 'Moya-ObjectMapper/RxSwift'
  pod 'SDWebImage', '~>3.8'
  pod 'Hero', '~> 0.3'
  pod 'UIScrollView-InfiniteScroll', '~> 1.0.0'

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
  end
