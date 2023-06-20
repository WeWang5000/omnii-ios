Pod::Spec.new do |s|
  s.name             = 'Pageable'
  s.version          = '1.0.0'
  s.summary          = 'A simple custom page view controller'
  s.homepage         = 'https://github.com/huxiaoyang'
#  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huyang' => 'yohuyang@gmail.com' }
  s.source           = { :git => '', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.source_files = 'Classes/**/*'
  s.swift_version = '5.0'
  
end
