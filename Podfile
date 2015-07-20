platform :ios, '7.0'

podspec
xcodeproj 'CIOAPIClient', 'Test' => :debug

# Enable TDOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING for the Test
# build config, for deterministic OAuth testing
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "TDOAuth"
            target.build_configurations.each do |config|
                if config.name == "Test"
                    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = "$(inherited) TDOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING=1"
                end
            end
        end
    end
end
