Pod::Spec.new do |s|
	s.name                  = 'InAppSettingsKit'
	s.version               = '2.6'
	s.summary               = 'This iPhone framework allows settings to be in-app in addition to being in the Settings app.'
	s.authors               = {"Ortwin Gentz" => "http://www.futuretap.com", "Luc Vandal" => "http://edovia.com/company/#contact_form"}
	s.social_media_url		= "https://twitter.com/IASettingsKit"
	s.homepage              = 'https://github.com/futuretap/InAppSettingsKit'
	s.license               = 'BSD'
	s.platform              = :ios, '6.0'
	s.requires_arc          = true
	s.source                = {git: 'https://github.com/futuretap/InAppSettingsKit.git', branch: 'master', tag: s.version.to_s}
	s.resource_bundles		= {"InAppSettingsKit" => "InAppSettingsKit/Resources/*"}
	s.source_files			= "InAppSettingsKit/**/*.{h,m}"
	s.frameworks			= "MessageUI", "UIKit"
end
