module Drupal
  module CCK
    module NodeMethods
      def cck_class
        @cck_class ||= eval("Drupal::#{type.camel_case}")
      end
    
      def cck
        @cck ||= cck_class.first(:nid => nid)
      end
    
      def find_or_create_cck
        return cck if cck
        @cck = cck_class.create! :vid => vid, :nid => nid
      end      
    end
    
    class ContentType
      eval Drupal.common
      storage_names[:drupal] = 'node_type'
      
      property :content_type, String,
        :key => true, :field => 'type'
    end
    
    class ContentNodeFieldInstance
      eval Drupal.common
      storage_names[:drupal] = 'content_node_field_instance'
      
      property :field_name, String,
        :length => 32, :key => true
      property :content_type, String,
        :length => 32, :key => true,
        :field => 'type_name'
        
      def field
        @field ||= ContentNodeField.first :field_name => field_name
      end
      
      def field_type
        @field_type ||= field.type
      end
      
      def to_s
        f = field_name.match(/^field_(.*)/)[1]
        case field_type
        when 'userreference'
          if through?
            r = "has 1, :#{f},
                   :class_name => Drupal::#{f.camel_case},
                   :child_key => [:nid]
                 
                 has 1, :#{f}_user,
                   :remote_name => :user,
                   :class_name => Drupal::User,
                   :child_key => [:nid],
                   :through => :#{f}"
          else
            r = "belongs_to :#{field_name},
              :class_name => 'Drupal::User'"
          end
        when 'number_integer'
          r  = "property :#{f}, Integer, 
                  :field => 'field_#{f}_value'"
        when 'text'
          r  = "property :#{f}, Text, 
                  :field => 'field_#{f}_value'"
        end
        r
      end
      
      def through?
        Drupal::CCK::Builder.fields.include? "content_#{field_name}"
      end
    end
    
    class ContentNodeField
      eval Drupal.common
      storage_names[:drupal] = 'content_node_field'
      
      property :type, String,
        :length => 127
      property :field_name, String,
        :length => 32
    end
  end
  
  Node.send :include, CCK::NodeMethods
end

require 'drupal/cck/fields.rb'
require 'drupal/cck/builder.rb'
