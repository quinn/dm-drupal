module Drupal
  module CCK
    class Builder
      def self.code
        types.
          map{|t| table = Table.new t}.
          select{|t| t.valid?}.
          join("\n")
      end

      def self.types
        @types ||= Drupal::Repository.adapter.query('select type from node').uniq
      end

      def self.fields
        @fields ||= Drupal::Repository.adapter.query('show tables').select{|t| t.match(/^content_field/)}
      end
    end
        
    class Table
      attr_accessor :content_type

      def initialize content_type
        self.content_type = content_type
      end

      def table
        "content_type_#{content_type}"
      end
      
      def fields
        Drupal::CCK::ContentNodeFieldInstance.all :content_type => content_type
      end
      
      def columns
        @columns ||= fields
      end

      def ignore_columns
        %w{nid vid}
      end

      def to_s
        "
          class #{type.camel_case}
            #{Drupal.common}
            storage_names[:drupal] = '#{table}'
            property :nid, Serial
            property :vid, Integer
            belongs_to :node,
              :child_key => [:nid]
            #{columns.map{|c| c.to_s}.join "\n"}
            def self.content_type; :#{content_type}; end
            extend CCK::FieldMethods
          end
        "
      end

      def valid?
        columns
        true
      rescue MysqlError
        false
      end
    end
  end
  
  def self.generate
    Drupal.class_eval do
      eval( CCK::Builder.fields.map do |field|
        CCK::ThroughField.new field
      end.join("\n") )
  
      eval CCK::Builder.code
    end
  end
end
