platform :ios, '26.0'

# Keep dependency deployment targets explicit when building with newer SDKs.
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '26.0'
    end
  end
end

target 'Accelerometer' do
  use_frameworks!

  pod 'RealmSwift'
  pod 'Realm'

  target 'AccelerometerTests' do
    inherit! :search_paths
  end

  target 'AccelerometerUITests' do
  end

end
