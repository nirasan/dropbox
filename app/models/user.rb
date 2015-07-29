class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :nodes
  has_many :event_logs

  after_create :create_root_node

  def root_node
    self.nodes.find_by(is_root: true)
  end

  def create_root_node
    # rootのデータってそもそも必要でしょうか？user_idに紐付いているのでparent_node_idがnullであればrootにあたいするフォルダ・ファイルは取得できるはず
    # > parent_node_idを参照してrootかどうか判断するというのはできるのですが、個人的には1カラムに復数の意味を持たせると不具合が発生しやすくなると思っているので原則やらないようにしています。
    # > node.is_rootではなくuser.root_node_idでもよかったとは思います。
    self.nodes.create(name: 'root', parent_node_id: 0, is_folder: true, is_root: true)
  end
end
