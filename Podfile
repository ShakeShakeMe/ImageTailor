SRC_ROOT = File.expand_path __dir__

target :ImageTailor do
  use_frameworks!
  platform :ios, '8.0'

	Dir.chdir SRC_ROOT do
		# dev extensions
		eval(File.open('PodDevExtension.rb').read) if File.exist? 'PodDevExtension.rb' and ENV['PODFILE_TYPE']=='DEV'
	end
  #pod 'Reveal-iOS-SDK', :configurations => ['Debug']
  #pod 'CTAssetsPickerController',  '~> 3.3.0'  
  pod 'BlocksKit',      '2.2.5'
  pod 'Masonry',        '1.1.0'
  pod 'MBProgressHUD',  '1.0.0'
  pod 'KVOController',  '1.2.0'
  pod 'libextobjc',        '0.4.1'
  pod 'IGListKit',      '3.1.1'
  #pod 'MJRefresh',      '3.1.14'
end
