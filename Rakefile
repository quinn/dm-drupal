require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "dm-drupal"
    gem.summary = %Q{Datamapper << Drupal}
    gem.description = %Q{A datamapper wrapper for a drupal database.. great for migrations}
    gem.email = "q.shanahan@gmail.com"
    gem.homepage = "http://github.com/quinn/dm-drupal"
    gem.authors = ["Quinn Shanahan"]
    gem.files = FileList['lib/**/*.rb'].to_a
    gem.add_dependency('datamapper', '>= 0.10.2')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

Jeweler::GemcutterTasks.new
