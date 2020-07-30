Pod::Spec.new do |s|
  s.name             = 'DMWEasyView'
  s.version          = '1.0.0'
  s.summary          = 'An easy-to-use view that simplifies touch handling logic'

  s.homepage         = 'https://github.com/yiyucanglang'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dahuanxiong' => 'xinlixuezyj@163.com' }
  s.source           = { :git => 'https://github.com/yiyucanglang/DMWEasyView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = '*.{h,m}'
 end
