class Node < ActiveRecord::Base
  belongs_to :user
  mount_uploader :file, UploadFileUploader

  default_value_for :is_root, false
  default_value_for :is_folder, false

  validate :validate_parent_node

  after_create :event_log_on_create
  after_update :event_log_on_update
  after_destroy :event_log_on_destroy

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

  scope :sort_by, -> (param) {
    if param.is_a?(String)
      sort_param = {
        name: 'name ASC',       name_desc: 'name DESC',
        type: 'is_folder ASC',  type_desc: 'is_folder DESC',
        date: 'updated_at ASC', date_desc: 'updated_at DESC'
      }[param.to_sym]
      if sort_param.present?
        order(sort_param)
      end
    end
  }

  def get_path (folders = nil)
    folders ||= self.user.nodes.where(is_folder: true).to_a
    path = [self]
    while !path[0].is_root do
      parent = folders.find{|node| node.id == path[0].parent_node_id}
      path.unshift(parent)
    end
    path
  end

  def get_path_string (path = nil)
    path ||= self.get_path
    path.map{|node| node.name}.join('/')
  end

  def event_log_on_create
    description = "「#{self.get_path_string}」を作成しました"
    self.user.event_logs.create(description: description)
  end

  def event_log_on_update
    if self.name_changed? || self.parent_node_id_changed?
      if self.parent_node_id_changed?
        before = Node.find(self.parent_node_id_was).get_path_string
        after = self.parent_node.get_path_string
      else
        before = after = self.parent_node.get_path_string
      end
      if self.name_changed?
        before += "/" + self.name_was
        after  += "/" + self.name
      else
        before += "/" + self.name
        after  += "/" + self.name
      end
      description = "「#{before}」を「#{after}」に変更しました"
      self.user.event_logs.create(description: description)
    end
  end

  def event_log_on_destroy
    description = "「#{self.get_path_string}」を削除しました"
    self.user.event_logs.create(description: description)
  end
end
