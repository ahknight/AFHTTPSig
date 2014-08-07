#
# Be sure to run `pod lib lint AFHTTPSig.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AFHTTPSig"
  s.version          = "1.0.0"
  s.summary          = "HTTPSig request signing"
  s.description      = <<-DESC
					   HTTPSig request signing for NSURLRequest and AFNetworking.
                       DESC
  s.homepage         = "https://github.com/ahknight/AFHTTPSig"
  s.license          = 'MIT'
  s.author           = { "Adam Knight" => "adam@movq.us" }
  s.source           = { :git => "https://github.com/ahknight/AFHTTPSig.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*.png'

//  # s.dependency 'AFNetworking', '~> 2.3'
end
