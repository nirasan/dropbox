class Node < ActiveRecord::Base
  extend Enumerize

  has_many :share_users
  belongs_to :user
  mount_uploader :file, UploadFileUploader

  # ポリモーフィックを使えばより簡単にフォルダかファイルデータを区別した管理ができると思います。
  # 参考サイト:http://ruby-rails.hatenadiary.com/entry/20141207/1417926599
  # > ポリモーフィックリレーション知りませんでした。便利そうですね。
  default_value_for :is_root, false
  default_value_for :is_folder, false

  enumerize :share_mode, in: {private: 0, public:1, limited:2}, default: :private

  validate :validate_parent_node

  before_create :set_file_or_folder
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
    if file.file.nil?
      self.is_folder = true
    else
      self.name = file.file.filename
    end
    self.share_path = SecureRandom.uuid
  end

  def validate_parent_node
    return if is_root
    parent_node = user.nodes.find_by(id: parent_node_id, is_folder: true)
    if parent_node.blank?
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

  def self.get_folder_tree (user)
    nodes = user.nodes.where(is_folder: true).to_a
    root_node = nodes.find{|node| node.is_root}
    {root_node => get_child_node_tree(root_node, nodes)}
  end

  def self.get_child_node_tree (parent_node, nodes)
    child_nodes = nodes.select{|node| node.parent_node_id == parent_node.id}
    tree = {}
    child_nodes.each do |node|
      tree[node] = get_child_node_tree(node, nodes)
    end
    tree
  end

  def move_to (parent_node_id)
    self.update(parent_node_id: parent_node_id)
  end

  def self.can_access_share_node? (user, parent, child)
    if parent.share_mode.private?
      return false
    elsif parent.share_mode.limited?
      if user.present?
        share_user = ShareUser.find_by(node: parent, user: user)
        return false unless share_user.present?
      else
        return false
      end
    end
    if child.present?
      child_path = child.get_path
      return false unless child_path.any?{|node| node == parent}
    end
    # returnはなくてもtrueだけで返る
    # > 最後の式の値が返るのは理解しているのですが、このメソッドのように真偽値を返すもので途中でreturnで抜けていく記述があるものは、最後の式でもreturnをつけたほうが読み心地がよい気がしてつけています。
    # > 数行程度のメソッドだったり、フローが一直線で単純なものなら return は不要とは思いますが、基準が曖昧なのでソニックガーデンで使用しているコーディング規約がありましたら教えていただきたいです。
    return true
  end
end
