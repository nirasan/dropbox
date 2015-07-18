class Node < ActiveRecord::Base
  belongs_to :user
  mount_uploader :file, UploadFileUploader

  default_value_for :is_root, false
  default_value_for :is_folder, false

  validate :validate_parent_node

  def parent_node
    Node.find(parent_node_id)
  end

  def child_nodes
    Node.where(parent_node_id: id)
  end

  def set_file_or_folder
    if self.file.file.nil?
      self.is_folder = true
    else
      self.name = self.file.file.filename
    end
  end

  def validate_parent_node
    parent_node = user.nodes.find_by(id: parent_node_id, is_folder: true)
    if !parent_node.present?
      errors.add(:parent_node_id, "invalid parent node.")
    end
  end

  def create_copy
    copy = self.dup
    copy.file = self.file.file
    copy.save
  end
end
