Pod::Spec.new do |s|
  s.version     		= "1.1.0"
  s.name        		= "SwiftyVK"
  s.summary     		= "SwiftyVK makes it easy to interact with social network VKontakte API for iOS and OSX"
  s.homepage    		= "https://github.com/WE-St0r/SwiftyVK"
  s.authors     		= { "Alexey Kudryavtsev" => "westor@me.com" }
  s.license     		= { :type => 'MIT'}

  s.requires_arc 		= true
  s.osx.deployment_target 	= "10.9"
  s.ios.deployment_target 	= "8.0"

  s.source      		= { :git => "https://github.com/WE-St0r/SwiftyVK.git" , :tag => s.version.to_s }
  s.source_files 		= "Source/**/*.*"
  s.ios.resources     		= "Resources/Bundles/SwiftyVKResources-iOS.bundle"
  s.osx.resources     		= "Resources/Bundles/SwiftyVKResources-OSX.bundle"
end
