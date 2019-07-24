use_frameworks!

target 'Icro' do
    pod 'ImageViewer', :git => 'https://github.com/hartlco/ImageViewer.git', :branch => 'master'
    pod 'AcknowList'
    pod 'SwiftLint'
    pod 'DropdownTitleView'
    pod 'Dequeueable'
	
	target 'IcroTests' do
	end
end

target 'IcroScreenshotsTests' do
end

def kitPods
  pod 'Kanna'
  pod 'wpxmlrpc'
end

target 'Icro-Share' do
  pod 'Kanna'
end

target 'IcroKit' do
    kitPods
end

target 'IcroUIKit' do
    kitPods
    pod 'Dequeueable'
end

target 'IcroKit-Mac' do
    platform :osx, '10.14'
    kitPods
end

target 'Icro-Mac' do
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DT_APP_EXTENSIONS=1'
        end
    end
end
