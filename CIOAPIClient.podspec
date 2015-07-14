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
  s.osx.deployment_target = '10.7'
  s.ios.frameworks = 'Security'

  s.default_subspec = 'Core'

  s.subspec "Core" do |sp|
      sp.source_files = 'CIOAPIClient/*.{h,m}'

      sp.dependency 'SSKeychain', '~> 1'
      sp.dependency 'TDOAuth', '~> 1.1'
  end

  s.subspec "AFNetworking1" do |sp|
    sp.source_files = "CIOAPIClient/AFNetworking1x"

    sp.dependency 'CIOAPIClient/Core'
    sp.dependency 'AFNetworking', '~> 1.0'
  end

end
