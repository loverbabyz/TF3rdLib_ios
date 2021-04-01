#
# Be sure to run `pod lib lint TFThirdLib_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TFThirdLib_iOS'
  s.version          = '1.0.1'
  s.summary          = '3rd lib for Treasure framework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  3rd lib for Treasure framework. 
                       DESC

  s.homepage         = 'https://github.com/loverbabyz/TF3rdLib_ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SunXiaofei' => 'daniel.xiaofei@gmail.com' }
  s.source           = { :git => 'https://github.com/loverbabyz/TF3rdLib_ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.requires_arc = true

  s.source_files = 'TFThirdLib_iOS/Classes/TFThirdLib_iOS.h'
  s.public_header_files = 'TFThirdLib_iOS/Classes/TFThirdLib_iOS.h'

  s.frameworks = "Foundation", "UIKit", "CoreGraphics", "CoreText", "CoreTelephony", "Security", "ImageIO", "QuartzCore", "SystemConfiguration"
  s.static_framework = true
  
  # core
  s.subspec 'Core' do |ss|
  ss.platform = :ios
  ss.source_files = 'TFThirdLib_iOS/Classes/Core-ThirdLib/*.{h,m,mm}'
  ss.public_header_files = 'TFThirdLib_iOS/Classes/Core-ThirdLib/*.h'
  end

  # Ada支付
  s.subspec 'Adapay' do |ss|
  ss.platform = :ios
  ss.frameworks = "Security", "QuartzCore"
  ss.libraries = "stdc++", "sqlite3"
  ss.source_files = 'TFThirdLib_iOS/Classes/AdaPay/*.{h,m,mm}'
  ss.public_header_files = 'TFThirdLib_iOS/Classes/AdaPay/*.h'
  ss.vendored_libraries = "TFThirdLib_iOS/Classes/3rd-framework/AdaPay/*.{a}"
  ss.vendored_frameworks = "TFThirdLib_iOS/Classes/3rd-framework/AdaPay/*.{framework}"
  ss.resources = "TFThirdLib_iOS/Classes/3rd-framework/AdaPay/*.{bundle}"
  ss.xcconfig = {
    'ENABLE_BITCODE' => 'NO'
    }
  ss.dependency  'TFThirdLib_iOS/Core'
  end
  
  # 微信
  s.subspec 'WeChat' do |ss|
  ss.platform = :ios
  ss.frameworks = "WebKit", "AudioToolbox", "CoreAudio", "MediaPlayer", "AVFoundation", "Security", "QuartzCore"
  ss.libraries = "stdc++", "sqlite3", "z", "c++"
  ss.source_files = 'TFThirdLib_iOS/Classes/WeChat/*.{h,m}'
  ss.public_header_files = 'TFThirdLib_iOS/Classes/WeChat/*.h'
  ss.vendored_libraries = "TFThirdLib_iOS/Classes/3rd-framework/WeChat/OpenSDK/*.{a}"
  ss.dependency 'TFThirdLib_iOS/Core'
  end
  
  # 微信分享
  s.subspec 'WXShare' do |ss|
  ss.platform = :ios
  ss.source_files = 'TFThirdLib_iOS/Classes/WXShare/*.{h,m}'
  ss.public_header_files = 'TFThirdLib_iOS/Classes/WXShare/*.h'
  ss.dependency  'TFThirdLib_iOS/WeChat'
  end
  
  # Bugly
  s.subspec 'Bugly' do |ss|
  ss.platform = :ios
  ss.frameworks = "SystemConfiguration", "Security"
  ss.library = 'c++','z'
  ss.source_files = 'TFThirdLib_iOS/Classes/Bugly/*.{h,m}'
  ss.public_header_files = 'TFThirdLib_iOS/Classes/Bugly/*.h'
  ss.dependency 'Bugly', '2.5.71'
  ss.dependency 'TFThirdLib_iOS/Core'
  end
  
  # 友盟统计
  s.subspec 'UMengSocial' do |ss|
  ss.frameworks = "SystemConfiguration", "CoreTelephony"
  ss.library = 'c++','z'
  ss.source_files = 'TFThirdLib_iOS/Classes/UMengSocial/*.{h,m}'
  ss.public_header_files = 'TFThirdLib_iOS/Classes/UMengSocial/*.h'
  ss.vendored_frameworks = "TFThirdLib_iOS/Classes/3rd-framework/UMCommon/*.{framework}"
  end
  
  # 极光推送
  s.subspec 'JPush' do |ss|
  ss.platform = :ios
  ss.source_files = 'TFThirdLib_iOS/Classes/JPush/*.{h,m}'
  ss.public_header_files = 'TFThirdLib_iOS/Classes/JPush/*.h'
  ss.libraries = "stdc++", "sqlite3"
  ss.vendored_libraries = "TFThirdLib_iOS/Classes/JPush/*.{a}"
  ss.dependency  'TFThirdLib_iOS/Core'
  end
  
  # 支付宝支付
  s.subspec 'AliPay' do |ss|
  ss.platform = :ios
  ss.frameworks = 'CoreMotion'
  ss.source_files = 'TFThirdLib_iOS/Classes/AliPay/**/*.{h,m}'
  ss.public_header_files = 'TFThirdLib_iOS/Classes/AliPay/**/*.h'
  ss.libraries = "stdc++", "sqlite3"
  ss.vendored_libraries = "TFThirdLib_iOS/Classes/AliPay/*.{a}"
  ss.vendored_frameworks = "TFThirdLib_iOS/Classes/AliPay/*.{framework}"
  ss.resources = "TFThirdLib_iOS/Classes/AliPay/*.{bundle}"
  ss.dependency  'TFThirdLib_iOS/Core'

    ss.subspec 'Util' do |sss|
    sss.platform = :ios
    sss.source_files = 'TFThirdLib_iOS/Classes/Alipay/Util/*.{h,m}'
    sss.public_header_files = 'TFThirdLib_iOS/Classes/Alipay/Util/*.h'
    end

  end
  
  s.dependency  'Aspects', '1.4.1'
  
end
