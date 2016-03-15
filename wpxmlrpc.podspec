Pod::Spec.new do |s|
  s.name         = "wpxmlrpc"
  s.version      = "0.8.2"
  s.summary      = "Lightweight XML-RPC library."
  s.homepage     = "https://github.com/wordpress-mobile/wpxmlrpc"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = {"WordPress", "Automattic" => "mobile@automattic.com"}
  s.source       = { :git => "https://github.com/wordpress-mobile/wpxmlrpc.git", :tag => "#{s.version}" }
  s.source_files = 'WPXMLRPC'
  s.libraries    = 'iconv'
  s.requires_arc = true

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
end
