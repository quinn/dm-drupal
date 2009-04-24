module Drupal
  class User
    eval Drupal.common
    storage_names[:drupal] = 'users'

    property :uid, Serial
    property :name, String,
      :length => 60,
      :nullable => false
    has n, :nodes, 
      :child_key => [:uid],
      :repository => Drupal::Repository
    
    def profile
      Drupal::Node.first :type => 'profile', :uid => uid
    end
  end
end
