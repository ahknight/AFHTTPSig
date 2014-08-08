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
	s.version          = "1.0.1"
	s.summary          = "Automatic HTTPSig request signing for AFNetworking."
	s.description      = <<-DESC
Includes a session manager (which you can use as a base class for your own session manager) that signs outgoing requests according to the IETF HTTP Signature draft specification.
DESC
	s.homepage         = "https://github.com/ahknight/AFHTTPSig"
	s.license          = 'MIT'
	s.author           = { "Adam Knight" => "adam@movq.us" }
	s.source           = { :git => "https://github.com/ahknight/AFHTTPSig.git", :tag => s.version.to_s }

	s.platform     = :ios, '6.0'
	s.requires_arc = true

	s.source_files = 'Pod/Classes'

	s.dependency 'AFNetworking', '~> 2.3'
	s.dependency 'CocoaSecurity', '~> 1.2'
end
