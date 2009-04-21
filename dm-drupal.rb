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
  
  class Node
    eval Drupal.common
    storage_names[:drupal] = 'node'

    property :nid, Serial
    property :vid, Integer
    property :type, String
    property :title, String
  end
  
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
    end
    
    class Column
      attr_accessor :name, :type, :col
      
      def initialize column
        self.col = column
        
        if m = column.field.match( /field_(.*)_value/ )
          self.name = m[1]
          self.type = column.type
        elsif m = column.field.match( /field_(.*)_uid/ )
          self.name = m[1]
          self.type = 'userreference'
        elsif m = column.field.match( /field_(.*)_nid/ )
          self.name = m[1]
          self.type = 'nodereference'
        else
          # fail # raise column.field
        end
      end
      
      def to_s
        if type == 'userreference'
          r = "belongs_to :#{name}, 
            :class_name => 'Drupal::User', 
            :child_key => [:#{col.field}]"
        elsif type == 'nodereference'
          r = "belongs_to :#{name}, 
            :class_name => 'Drupal::Node', 
            :child_key => [:#{col.field}]"
        elsif type
          r = "property :#{name}, #{type}"
          r += ", :length => #{length}" if length
          r += ", :field => '#{col.field}'"
        end
        r
      end
      
      def type
        case @type
        when /varchar/
          'String'
        when /int/
          'Integer'
        when /longtext/
          'Text'
        when /datetime/
          'DateTime'
        else
          @type
        end
      end
      
      def length
        @length ||= @type.match( /.*\((.*)\)/ )
        return @length[1] if @length
      end
    end
    
    class Table
      attr_accessor :type
      
      def initialize type
        self.type = type
      end
      
      def table
        "content_type_#{type}"
      end
      
      def columns
        @columns ||= Drupal::Repository.
          adapter.
          query("desc #{table}").
          map do |c| 
            unless ignore_columns.include? c.field
              Column.new c
            end
          end.compact
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
            belongs_to :node,
              :child_key => [:nid]
            #{columns.join "\n"}
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
  
  Node.send :include, CCK::NodeMethods
  eval CCK::Builder.code
end
