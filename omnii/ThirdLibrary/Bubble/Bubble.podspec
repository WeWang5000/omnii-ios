Pod::Spec.new do |s|
  s.name             = 'Bubble'
  s.version          = '1.0.0'
  s.summary          = 'A simple custom bubble view'
  s.homepage         = 'https://github.com/huxiaoyang'
#  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huyang' => 'yohuyang@gmail.com' }
  s.source           = { :git => '', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.source_files = 'Classes/**/*'
  s.swift_version = '5.0'

  s.dependency 'DynamicBlurView', '~> 5.0'
  s.dependency 'SwifterSwift'
  s.dependency 'CommonUtils'
end
