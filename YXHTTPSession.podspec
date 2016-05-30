#
# Be sure to run `pod lib lint YXHTTPSession.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "YXHTTPSession"
  s.version          = "0.1.2"
  s.summary          = "A simple network base on NSURLSession."
  s.homepage         = "https://github.com/shuleihen/YXHTTPSession"
  s.license          = 'MIT'
  s.author           = { "zdy" => "shuleihen@126.com" }
  s.source           = { :git => "https://github.com/shuleihen/YXHTTPSession.git", :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.source_files = 'YXHTTPSession/Classes/**/*'
  s.dependency 'MJExtension', '~> 3.0.10'
end
