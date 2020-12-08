Pod::Spec.new do |spec|

  spec.name         = "DocX"
  spec.version      = "0.0.17"
  spec.summary      = "DocX creates .docx file from string"
  spec.description  = <<-DESC
	This library helps you create docx file and share.
                   DESC

  spec.homepage      = "https://github.com/mahmut-codeway/DocX"
  spec.license       = { :type => "MIT", :file => "LICENSE" }
  spec.author	     = { "Mahmut Şahin" => "mahmut@codeway.co" }
  spec.source        = { :git => "https://github.com/mahmut-codeway/DocX.git", :tag => "0.0.17" }

  spec.source_files  = "DocX/**/*.{h,m,swift}"

  spec.ios.deployment_target = "12.0"
  spec.swift_version = "5.0"

  spec.dependency 'AEXML'
  spec.dependency 'SSZipArchive'

end
