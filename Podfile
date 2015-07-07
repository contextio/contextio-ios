platform :ios, '7.0'
podspec

# Enable TDOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING for the Test
# build config, for deterministic OAuth testing
post_install do |installer|
    installer.project.targets.each do |target|
        if target.name == "Pods-TDOAuth"
            target.build_configurations.each do |config|
                if config.name == "Test"
                    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = "$(inherited) TDOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING=1"
                end
            end
        end
    end
end
