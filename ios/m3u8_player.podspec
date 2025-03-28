Pod::Spec.new do |s|
  s.name             = 'm3u8_player'
  s.version          = '0.0.6'
  s.summary          = 'A Flutter M3U8 player plugin'
  s.description      = 'A Flutter package that provides a customizable M3U8 player for both mobile and web platforms.'
  s.homepage         = 'https://github.com/MendesCorporation/m3u8_player'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Mendes Corporation' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end