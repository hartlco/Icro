Pod::Spec.new do |s|
  s.name         = "WPXMLRPC"
  s.version      = "0.9"
  s.summary      = "Lightweight XML-RPC library."
  s.homepage     = "https://github.com/wordpress-mobile/wpxmlrpc"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = "WordPress"
  s.source       = { :git => "https://github.com/wordpress-mobile/wpxmlrpc.git", :tag => "0.9" }
  s.source_files = 'WPXMLRPC'
  s.public_header_files = [ 'WPXMLRPC/WPXMLRPC.h', 'WPXMLRPC/WPXMLRPCRequest.h', 'WPXMLRPC/WPXMLRPCResponse.h' ]
  s.frameworks   = 'libiconv.dylib'
  s.requires_arc = true

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'

  s.documentation = {
    :appledoc => [ 'AppledocSettings.plist' ]
  }
end
