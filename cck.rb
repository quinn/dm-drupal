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
    
    class ContentNodeFieldInstance
      eval Drupal.common
      storage_names[:drupal] = 'content_node_field_instance'
      
      property :field_name, String,
        :length => 32, :key => true
      property :type_name, String,
        :length => 32, :key => true
        
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
              :child_key => [:#{field_name}_uid]"
          else
            r = "belongs_to :#{field_name},
              :class_name => 'Drupal::User'"
          end
        # when 'nodereference'
        #   r = "belongs_to :#{field_name},
        #     :class_name => 'Drupal::Node', 
        #     :child_key => [:#{field_name}_nid]"
        # else
        #   r = "property :#{field_name}, #{type}"
        #   r += ", :field => '#{field_name}_value'"
        end
        r
      end
      
      def through?
        false
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
