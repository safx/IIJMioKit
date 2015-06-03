Pod::Spec.new do |s|
  s.name         = "IIJMioKit"
  s.version      = "0.0.3"
  s.summary      = "An unofficial web API client for IIJMio Coupon API"
  s.homepage     = "https://github.com/safx/IIJMioKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "MATSUMOTO Yuji" => "safxdev@gmail.com" }
  s.source       = { :git => "https://github.com/safx/IIJMioKit.git", :tag => s.version }
  s.source_files = "IIJMioKit/*.swift"
  s.ios.deployment_target = "8.2"
  s.requires_arc = true
end
