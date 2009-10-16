module Drupal
  module CCK
    module FieldMethods
      def fields
        Drupal::CCK::ContentNodeFieldInstance.all :type_name => type
      end
    end
    
    class ThroughField
      attr_accessor :field_name, :table
      
      def initialize field
        self.table = field
        self.field_name = field.match(/^content_field_(.*)/)[1]
      end
      
      def field
        @field ||= ContentNodeField.first :field_name => "field_#{field_name}"
      end
      
      def valid?
        !field.nil?
      end
      
      def field_type
        case field.type
        when 'userreference'
          "belongs_to :user,
            :class_name => 'Drupal::User',
            :child_key => [:#{field.field_name}_uid]"
        end
      end
      
      def to_s
        return "" unless valid?
        "
          class #{field_name.camel_case}
            #{Drupal.common}
            storage_names[:drupal] = '#{table}'
            
            property :vid, Integer, :key => true
            belongs_to :node,
              :class_name => 'Drupal::Node',
              :child_key => [:nid]
            Drupal::User
            #{field_type}
          end
        "
      end
    end
  end
end
