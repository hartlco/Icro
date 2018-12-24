use_frameworks!
inhibit_all_warnings!

target 'Icro' do
    pod 'SDWebImage/GIF'
    pod 'ImageViewer', :git => 'https://github.com/MailOnline/ImageViewer.git', :commit => 'a4de06a08a78c4b0a65a48aa891f755b64ff03a8'
    pod 'DTCoreText'
    pod 'AcknowList'
	pod 'SwiftLint'
    pod 'DropdownTitleView'
    pod 'SwiftGen'
	
	target 'IcroTests' do
	end
end

target 'Icro-Share' do
    pod 'Kanna'
end

def kitPods
    pod 'Kanna'
    pod 'KeychainAccess'
    pod 'wpxmlrpc'
    pod 'Alamofire', '~> 4.7'
end

target 'IcroKit' do
    kitPods
    pod 'DTCoreText'
end

target 'IcroUIKit' do
    kitPods
    pod 'SDWebImage/GIF'
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
        if ['ImageViewer'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end

        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DT_APP_EXTENSIONS=1'
        end
    end
end
