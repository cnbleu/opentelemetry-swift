#
#  Be sure to run `pod spec lint OpenTelemetrySdk.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name             = "OpenTelemetryApi"
  spec.version          = '0.0.7'
  spec.summary          = 'OpenTelemetryApi Objc wrapper'

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description      = <<-DESC
  log service ios producer.
  https://help.aliyun.com/document_detail/29063.html
  https://help.aliyun.com/product/28958.html
                         DESC

  spec.homepage         = 'https://github.com/cnbleu/opentelemetry-swift'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { "cnbleu" => "keyu404@gmail.com" }
  spec.source           = { :git => 'https://github.com/cnbleu/opentelemetry-swift.git', :tag => spec.version.to_s }
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  
  spec.ios.deployment_target = '10.0'
#  spec.default_subspec = 'Api'
  spec.swift_versions = '5.2'

  spec.requires_arc  = true
  spec.libraries = 'z'
  spec.source_files = 'Sources/OpenTelemetryApi/**/*.{swift}'

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-ObjC'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }

end
