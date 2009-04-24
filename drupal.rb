module Drupal
  RepositoryName = :drupal
  Repository = repository(Drupal::RepositoryName)
  
  def self.common
    "
      include DataMapper::Resource
    
      def self.default_repository_name
        Drupal::RepositoryName
      end
    "
  end
end

$:<< File.expand_path(Pathname.new(__FILE__).dirname)
require 'drupal/user'
require 'drupal/node'
require 'drupal/cck'
