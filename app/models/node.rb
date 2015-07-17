class Node < ActiveRecord::Base
  belongs_to :user
  mount_uploader :file, UploadFileUploader

  validate :validate_parent_node

  def parent_node
    Node.find(parent_node_id)
  end

  def child_nodes
    Node.where(parent_node_id: id)
  end

  def validate_parent_node
    parent_node = user.nodes.find_by(id: parent_node_id, is_folder: true)
    if !parent_node.present?
      errors.add(:parent_node_id, "invalid parent node.")
    end
  end
end
