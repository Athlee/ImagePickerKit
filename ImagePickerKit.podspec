Pod::Spec.new do |s|

s.name         = "ImagePickerKit"
s.version      = "0.1.0"
s.summary      = "ImagePickerKit is a protocol-oriented framework that provides handly features to dealing with picking or taking a photo!"
s.homepage     = "https://github.com/Athlee/ImagePickerKit"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Eugene Mozharovsky" => "mozharovsky@live.com" }
s.social_media_url   = "http://twitter.com/dottieyottie"
s.platform     = :ios, "9.0"
s.ios.deployment_target = "9.0"
s.source       = { :git => "https://github.com/Athlee/ImagePickerKit.git", :tag => s.version }
s.source_files  = "Source/*.swift"
s.requires_arc = true

end
