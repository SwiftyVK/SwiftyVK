Pod::Spec.new do |s|
  s.version                 = "3.0.2"
  s.name                    = "SwiftyVK"
  s.summary                 = "Easy and powerful way to interact with VK API for iOS and macOS"
  s.homepage                = "https://github.com/SwiftyVK/SwiftyVK"
  s.authors                 = { "Alexey Kudryavtsev" => "westor@me.com" }
  s.license                 = { :type => 'MIT', :file => 'LICENSE.txt'}

  s.requires_arc            = true
  s.osx.deployment_target 	= "10.10"
  s.ios.deployment_target 	= "8.0"

  s.source                  = { :git => "https://github.com/SwiftyVK/SwiftyVK.git" , :tag => s.version.to_s }
  s.source_files            = "Library/Sources/**/*.*"
  s.ios.source_files        = "Library/UI/iOS"
  s.osx.source_files        = "Library/UI/macOS"
  s.ios.resources           = "Library/Resources/Bundles/SwiftyVK_resources_iOS.bundle"
  s.osx.resources           = "Library/Resources/Bundles/SwiftyVK_resources_macOS.bundle"
end
