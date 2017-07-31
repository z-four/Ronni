#
# Be sure to run `pod lib lint Pod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Ronni'
  s.version          = '1.0.4'
  s.summary          = 'Library that will make the task of display messages simple'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A convenient and easy to use library that will make the task of display messages simple'

  s.homepage         = 'https://github.com/z-four/Ronni'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dmitriy Zhyzhko' => 'zhyzhkodim@gmail.com' }
  s.source           = { :git => 'https://github.com/z-four/Ronni.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Ronni/Classes/**/*.swift'
  s.resource_bundles = {'Ronni' => ['Ronni/Resources/**/*.{xib,xcassets}']}

  s.requires_arc = true

end
