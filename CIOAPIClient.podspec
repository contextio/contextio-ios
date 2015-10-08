Pod::Spec.new do |s|
  s.name         = "CIOAPIClient"
  s.version      = "1.0"
  s.summary      = "API Client for Context.IO Email API"
  s.description  = "Build awesome things with email! We take the pain out of syncing email data with your app so you can focus on what makes your product great."
  s.homepage     = "https://github.com/contextio/contextio-ios"
  s.license      = 'MIT'
  s.author       = { 'Context.IO' => 'support@context.io' }
  s.social_media_url = "https://twitter.com/contextio"
  s.source       = { :git => "https://github.com/contextio/contextio-ios.git", :tag => s.version }
  s.requires_arc = true

  s.source_files = 'CIOAPIClient/**/*.{h,m}'
  s.private_header_files = 'CIOAPIClient/Vendor/**/*.h'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'

  s.ios.frameworks = 'Security'
  s.dependency 'SSKeychain', '~> 1'
end
