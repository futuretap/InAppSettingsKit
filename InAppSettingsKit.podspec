Pod::Spec.new do |s|
	s.name                  = 'InAppSettingsKit'
	s.version               = '2.13'
	s.summary               = 'This iPhone framework allows settings to be in-app in addition to being in the Settings app.'

  s.description      = <<-DESC
InAppSettingsKit (IASK) is an open source solution to easily add in-app settings to your iPhone apps. Normally iOS apps use the Settings.bundle resource to make app's settings to be present in "Settings" app. InAppSettingsKit takes advantage of the same bundle and allows you to present the same settings screen within your app - in addition or instead of in the Settings app. For in-app settings, IASK offers a large number of additional configuration options.
                       DESC

	s.authors               = {"Ortwin Gentz" => "http://www.futuretap.com", "Luc Vandal" => "http://edovia.com/company/#contact_form"}
	s.social_media_url		= "https://twitter.com/IASettingsKit"
	s.homepage              = 'https://github.com/futuretap/InAppSettingsKit'
	s.license               = 'BSD'
	s.requires_arc          = true
	s.source                = {git: 'https://github.com/futuretap/InAppSettingsKit.git', branch: 'master', tag: s.version.to_s}
	s.resource_bundles		= {"InAppSettingsKit" => "InAppSettingsKit/Resources/*"}
	s.source_files			= "InAppSettingsKit/**/*.{h,m}"
	s.frameworks			= "MessageUI", "UIKit"
	s.ios.deployment_target = '8.0'
end
