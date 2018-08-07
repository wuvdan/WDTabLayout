
Pod::Spec.new do |s|

  s.name         = "WDTabLayout"
  s.version      = "0.0.1"
  s.summary      = "简易的头部视图控制器"
  s.homepage     = "https://github.com/wudan-ios"
  s.license      = "MIT"
  s.author       = { "xlz520" => "xlz521w@163.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/wudan-ios/WDTabLayout.git", :tag => "#{s.version}" }
  s.source_files  = "WDTabLayout", "WDTabLayout/*.{h,m}"
  s.requires_arc = true


end
