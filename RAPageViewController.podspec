Pod::Spec.new do |s|
  s.name         = "RAPageViewController"
  s.version      = "1.0.0"
  s.summary      = "Sliding pages side by side, infinitely."
  s.homepage     = "https://github.com/evadne/RAPageViewController"
  s.author       = { "Evadne Wu" => "ev@radi.ws" }
  s.source       = { :git => "https://github.com/evadne/RAPageViewController.git" }
  s.platform     = :ios, '6.0'
  s.source_files = 'RAPageViewController', 'RAPageViewController/**/*.{h,m}'
  s.frameworks = 'QuartzCore', 'UIKit'
  s.requires_arc = true
end
