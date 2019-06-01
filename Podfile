use_frameworks!
inhibit_all_warnings!

target 'Icro' do
    pod 'ImageViewer', :git => 'https://github.com/hartlco/ImageViewer.git', :branch => 'master'
    pod 'DTCoreText'
    pod 'AcknowList'
    pod 'SwiftLint'
    pod 'DropdownTitleView'
    pod 'SwiftGen'
    pod 'Kingfisher'
    pod 'AppDelegateComponent'
    pod 'Dequeueable'
	
	target 'IcroTests' do
	end
end

target 'IcroScreenshotsTests' do
end

target 'Icro-Share' do
    pod 'Kanna'
end

def kitPods
    pod 'Kanna'
    pod 'KeychainAccess'
    pod 'wpxmlrpc'
    pod 'Alamofire', '~> 4.7'
    pod 'PromiseKit', '~> 6.8'
end

target 'IcroKit' do
    kitPods
    pod 'DTCoreText'
end

target 'IcroUIKit' do
    kitPods
    pod 'Kingfisher'
    pod 'Dequeueable'
end

target 'IcroKit-Mac' do
    platform :osx, '10.14'
    kitPods
end

target 'Icro-Mac' do
  pod 'Kingfisher'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DT_APP_EXTENSIONS=1'
        end
    end
end
