chef_dir = File.join(File.expand_path(File.dirname(__FILE__)), 'chef')

cache_options({
  :path => File.join(chef_dir, 'cache', 'checksums'),
  :skip_expires => true
})

cookbook_path     File.join(chef_dir,   'cookbooks')
file_cache_path   File.join(chef_dir,   'cache')
log_level         :info
