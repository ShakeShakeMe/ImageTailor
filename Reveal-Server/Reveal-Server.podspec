Pod::Spec.new do |s|
  s.name             = 'Reveal-Server'
  s.version          = (require 'bbsp/smart_version'; BBSP::smart_version)
  s.summary          = 'Reveal-iOS-SDK.'
  s.homepage         = 'http://git.husor.com/Pods/RReveal-Server'
  s.license          = { :type => 'proprietary', :text => 'Husor Inc. Copyright' }
  s.author           = { 'li.ding' => 'li.ding@husor.com' }
  s.source           = { :git => 'http://git.husor.com/Pods/Reveal-Server.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.ios.vendored_frameworks = "vendor/RevealServer.framework" 
  s.frameworks = 'UIKit', 'QuartzCore'

end
