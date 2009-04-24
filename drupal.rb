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
  
  class PostHook
    attr_accessor :cls, :proc
    
    def load
      cls.class_eval &proc
    end
        
    def initialize cls, proc
      self.cls  = cls
      self.proc = proc
    end
  end
  
  def self.hooks
    @hooks||= []
    @hooks
  end
  
  def self.hooks= hook
    hooks
    @hooks << hook
  end
end

module DataMapper::Resource::ClassMethods
  def post_drupal &blk
    Drupal.hooks = Drupal::PostHook.new self, blk
  end
end

$:<< File.expand_path(Pathname.new(__FILE__).dirname)
require 'drupal/user'
require 'drupal/node'
require 'drupal/cck'
