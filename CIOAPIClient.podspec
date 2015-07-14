Pod::Spec.new do |s|
  s.name         = "CIOAPIClient"
  s.version      = "0.9.0-pre"
  s.summary      = "API Client for Context.IO."
  s.homepage     = "https://github.com/contextio/contextio-ios"
  s.license      = 'MIT'
  s.author       = { 'Kevin Lord' => 'kevinlord@otherinbox.com' }
  s.source       = { :git => "https://github.com/contextio/contextio-ios.git", :tag => '0.9.0-pre1' }
  s.source_files = 'CIOAPIClient', 'CIOAPIClient/OAuth', 'CIOAPIClient/OAuth/Crypto'
  s.requires_arc = true

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.ios.frameworks = 'Security'

  s.source_files = 'CIOAPIClient/*.{h,m}'
  s.dependency 'SSKeychain', '~> 1'
  s.dependency 'TDOAuth', '~> 1.1'

end
