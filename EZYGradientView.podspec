Pod::Spec.new do |s|

  s.name              = 'EZYGradientView'
  s.version           = '1.5.1'
  s.platform          = :ios, '8.0'
  s.license           = { :type => 'MIT' }
  s.homepage          = 'https://github.com/shashankpali/EZYGradientView'
  s.authors           = { 'Shashank Pali' => 'shank.pali@gmail.com' }
  s.summary           = 'Create gradients and blur gradients without a single line of code'
  s.source            = { :git => 'https://github.com/qranio-com/EZYGradientView.git', :tag => s.version }
  s.source_files      = 'EZYGradientView/*.swift'
  s.requires_arc      = true
end