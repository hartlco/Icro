use_frameworks!

target 'Icro' do

	target 'IcroTests' do
	end
end

target 'IcroScreenshotsTests' do
end

def kitPods
end

target 'Icro-Share' do
end

target 'IcroKit' do
    kitPods
end

target 'IcroUIKit' do
    kitPods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DT_APP_EXTENSIONS=1'
        end
    end
end
