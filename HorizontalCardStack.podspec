#
# Be sure to run `pod lib lint HorizontalCardStack.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HorizontalCardStack'
  s.version          = '0.1.0'
  s.summary          = 'HorizontalCardStack is a library designed to simplify the implementation of Linkedin like cards on iOS. (Next, Delete functionality)'
  s.description      = 'Swipable, customizable card stack view, Linkedin like card stack view based on UICollectionView. Cards UI'
  s.homepage         = 'https://github.com/pitsko/HorizontalCardStack'
  s.license          = { :type => "Apache 2.0 License", :file => "LICENSE.txt" }
  s.author           = { 'andrei.pitsko' => 'andrei.pitsko@gmail.com' }
  s.source           = { :git => 'https://github.com/pitsko/HorizontalCardStack.git', :tag => s.version.to_s }
  s.social_media_url   = "http://twitter.com/tispr"
  s.ios.deployment_target = '10.0'
  s.source_files = 'HorizontalCardStack/Classes/**/*'
  s.requires_arc = true
end
