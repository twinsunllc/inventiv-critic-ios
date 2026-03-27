Pod::Spec.new do |s|
  s.name             = 'Critic'
  s.version          = '1.0.0'
  s.summary          = 'iOS SDK for collecting actionable customer feedback via Inventiv Critic.'

  s.description      = <<-DESC
iOS SDK for collecting actionable customer feedback via Inventiv Critic.
Uses native URLSession and device APIs with no external dependencies.
                       DESC

  s.homepage         = 'https://github.com/twinsunllc/inventiv-critic-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Twin Sun' => 'dev@twinsun.com' }
  s.source           = { :git => 'https://github.com/twinsunllc/inventiv-critic-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '16.0'
  s.swift_version = '6.0'

  s.source_files = 'Sources/Critic/**/*.swift'
end
