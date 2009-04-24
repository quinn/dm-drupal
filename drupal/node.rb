module Drupal
  class Node
    eval Drupal.common
    storage_names[:drupal] = 'node'

    property :nid, Serial
    property :vid, Integer
    property :uid, Integer
    property :type, String
    property :title, String
    
    before :save, :assign_vid
    after :save, :write_node_revision
    
    def assign_vid
      return true unless vid.nil? 
      self.vid ||= Drupal::Node.all.last.nid + 1
      save!
      self.vid = nid
      save!
    end
    
    def write_node_revision
      find_or_init_node_revision.attributes = {
        :nid     => nid,
        :vid     => vid, 
        :uid     => uid, 
        :title   => title,
        :body    => '',
        :teaser  => '',
        :log     => ''
      }
      node_revision.save!
    end
    
    def find_or_init_node_revision
      return node_revision if node_revision
      @node_revision = Drupal::NodeRevision.new
    end
    
    def node_revision
      @node_revision ||= Drupal::NodeRevision.get vid
    end
  end
  
  class NodeRevision
    eval Drupal.common
    storage_names[:drupal] = 'node_revisions'

    property :vid, Serial
    property :nid, Integer
    property :uid, Integer
    property :title, String
    property :body, Text
    property :teaser, Text
    property :log, Text
  end
end
