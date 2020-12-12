Pod::Spec.new do |s|
  s.name             = 'YZChat'
  s.version          = '0.1.0'
  s.summary          = 'A short description of YZChat.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/QiaoBangZhu/YZChat'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'QiaoBangZhu' => 'ios9001@foxmail.com' }
  s.source           = { :git => 'https://github.com/QiaoBangZhu/YZChat.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '11.0'

  s.source_files = 'YZChat.framework/Headers/*.{h}'
  s.public_header_files = 'YZChat.framework/Headers/*.{h}'
  s.resources = ['YZChat.framework/YZChatResource.bundle', 'YZChat.framework/TUIKitResource.bundle', 'YZChat.framework/TUIKitFace.bundle']
  s.vendored_frameworks = 'YZChat.framework', 'YZChat/Vendors/*.framework'

  s.dependency 'AFNetworking', '~> 4.0'
  s.dependency 'QMUIKit'
  s.dependency 'Masonry'
  s.dependency 'YYModel'
  s.dependency 'YYText'
  s.dependency 'IQKeyboardManager'
  s.dependency 'MJExtension'
  s.dependency 'FCFileManager'
  s.dependency 'BlocksKit'
  s.dependency 'Bugly'
  s.dependency 'ZXingObjC'
  
  s.dependency 'MMLayout', '~> 0.2.0'
  s.dependency 'SDWebImage','~> 5.9.0'
  s.dependency 'ReactiveObjC', '~> 3.1.1'
  s.dependency 'Toast', '~> 4.0.0'
  s.dependency 'TXLiteAVSDK_TRTC', '~> 7.8.9515'

  s.dependency 'AMap3DMap-NO-IDFA'
  s.dependency 'AMapSearch-NO-IDFA'
end
