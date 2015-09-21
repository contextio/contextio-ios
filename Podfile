
target 'CIOAPIClient iOS' do
    platform :ios, '7.0'
    pod 'TDOAuth', git: "git@github.com:Pretz/TDOAuth.git"
    pod 'SSKeychain', '~> 1'
end

target 'CIOAPIClient Mac' do
    platform :osx, '10.9'
    pod 'TDOAuth', git: "git@github.com:Pretz/TDOAuth.git"
    pod 'SSKeychain', '~> 1'
end

xcodeproj 'CIOAPIClient', 'Test' => :debug

# Enable TDOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING for the Test
# build config, for deterministic OAuth testing
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name.include? "TDOAuth"
            target.build_configurations.each do |config|
                if config.name == "Test"
                    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = "$(inherited) TDOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING=1"
                end
            end
        end
    end
end
