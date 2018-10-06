use_frameworks!
inhibit_all_warnings!

target 'Icro' do
    pod 'SDWebImage/GIF'
    pod 'FontAwesome.swift'
    pod 'wpxmlrpc'
    pod 'SwiftMessages'
    pod 'ImageViewer', :git => 'https://github.com/MailOnline/ImageViewer.git', :commit => 'a4de06a08a78c4b0a65a48aa891f755b64ff03a8'
    pod 'DTCoreText'
    pod 'AcknowList'
    pod 'Keyboard+LayoutGuide'
    pod 'Alamofire', '~> 4.7'
	pod 'SwiftLint'
	
	target 'IcroTests' do
	end
end

def kitPods
    pod 'Kanna'
    pod 'KeychainAccess'
end

target 'IcroKit' do
    kitPods
    pod 'DTCoreText'
end

target 'IcroKit-Mac' do
    platform :osx, '10.14'
    kitPods
end

target 'Icro-Mac' do
    pod 'Kingfisher'
end
