Pod::Spec.new do |s|
  s.name         = 'm3u8_player'
  s.version      = '0.0.4'
  s.summary      = 'A Flutter package that provides a customizable M3U8 player for both mobile and web platforms.'
  s.description  = <<-DESC
A Flutter package that provides a customizable M3U8 player for both mobile and web platforms.
                   DESC
  s.homepage     = 'https://github.com/MendesCorporation/m3u8_player'
  s.license      = { :file => '../LICENSE' }
  s.author       = { 'MendesCorporation' => 'email@example.com' }
  s.source       = { :git => 'https://github.com/MendesCorporation/m3u8_player.git', :tag => s.version.to_s }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform     = :ios, '9.0'
end