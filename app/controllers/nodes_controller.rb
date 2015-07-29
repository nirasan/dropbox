class NodesController < ApplicationController
  before_action :authenticate_user!, except: [:share]
  before_action :set_node, only: [
      :new_file, :new_folder, :list, :edit, :update, :destroy, :download, :copy, :move_folder_list, :move,
      :share_setting, :change_share_setting, :create_share_user, :destroy_share_user,
    ]

  def index
    # listアクションを利用する意味はありますか？indexで良いのでは？nodeのIDが指定されたら(フォルダが選択されたら)showアクションにすれば良さそう
    # だが人によって意見が変わりそうなので、自分だったらそうするかなー程度。
    # > id 指定なしでルートフォルダーを表示するアクションが欲しかったので index をこのような形にしましたが、ルートフォルダーのリンクを作るヘルパーを作るなどしたほうがよいかもしれませんね。
    # > list は show でいいのでは？というのはそのとおりだと思います。
    redirect_to list_node_path(current_user.root_node)
  end

  # フォルダ配下のファイル一覧
  def list
    @nodes = @node.child_nodes.sort_by(params['sort'])
  end

  def search
    # 参考までにですが、検索はransackというgemが便利
    # > 存在は知っていましたが単純な検索なので不要と考えました。
    # > 改めて確認したところ、空白区切りの複数単語検索をしたい場合などは、今回の程度の検索でも導入したほうが便利そうですね。
    @nodes = current_user.nodes.where('name LIKE ?', "%#{params['search']}%")
  end

  def new_file
  end

  def new_folder
  end

  def edit
  end

  def create
    # paramsを利用するときはxxx_paramsメソッドをよく使います
    # @node = current_user.nodes.build(node_params)
    # > create と update で許可したいパラメータが異なるため、それぞれで xxx_params を展開した結果このような書き方になっています。
    @node = current_user.nodes.build(params.require(:node).permit(:name, :file, :parent_node_id))
    respond_to do |format|
      if @node.save
        format.html { redirect_to list_node_path(@node.parent_node), notice: '作成に成功しました。' }
      else
        format.html { render :new_file }
      end
    end
  end

  def update
    respond_to do |format|
      if @node.update(params.require(:node).permit(:name))
        format.html { redirect_to list_node_path(@node.parent_node), notice: '名前を変更しました。' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @node.destroy
    respond_to do |format|
      format.html { redirect_to list_node_path(@node.parent_node), notice: '削除しました。' }
    end
  end

  def download
    if @node.is_folder
      redirect_to list_node_path(@node.parent_node)
    end
    filepath = @node.file.current_path
    stat = File::stat(filepath)
    send_file(filepath, :filename => @node.file.file.filename, :length => stat.size)
  end

  def copy
    respond_to do |format|
      if @node.create_copy
        format.html { redirect_to list_node_path(@node.parent_node), notice: 'コピーしました。' }
      else
        format.html { redirect_to list_node_path(@node.parent_node), alert: 'コピーに失敗しました。' }
      end
    end
  end

  def move_folder_list
    @tree = Node.get_folder_tree(current_user)
  end

  def move
    respond_to do |format|
      if @node.move_to(params['node_id'])
        format.html { redirect_to list_node_path(@node.parent_node), notice: '移動しました。' }
      else
        format.html { redirect_to list_node_path(@node.parent_node), alert: '移動に失敗しました。' }
      end
    end
  end

  def share_setting
  end

  def change_share_setting
    respond_to do |format|
      if @node.update(params.require(:node).permit(:share_mode))
        format.html { redirect_to share_setting_node_path(@node), notice: '共有設定を変更しました。' }
      else
        format.html { render :share_setting }
      end
    end
  end

  def create_share_user
    # 存在しないユーザのメールアドレスが入力された場合エラーとなる
    # > find_by! に変更して not found になるようにします。
    user = User.find_by(email: params['email'])
    share_user = ShareUser.new(node: @node, user: user)
    respond_to do |format|
      if share_user.save
        format.html { redirect_to share_setting_node_path(@node), notice: '共有するユーザーを追加しました。' }
      else
        format.html { render :share_setting }
      end
    end
  end

  def destroy_share_user
    user = User.find(params['user_id'])
    share_user = ShareUser.find_by(node: @node, user: user)
    share_user.destroy
    respond_to do |format|
      format.html { redirect_to share_setting_node_path(@node), notice: '共有するユーザーを削除しました。' }
    end
  end

  def share
    @parent_node = Node.find_by!(share_path: params['share_path'])
    @child_node = Node.find_by(id: params['node_id'])
    unless Node.can_access_share_node(current_user, @parent_node, @child_node)
      return head 403
    end
    if @child_node.present?
      @node = @child_node
      if @child_node.is_folder
        @nodes = @child_node.child_nodes
      else
        download
      end
    else
      @node = @parent_node
      if @node.is_folder
        @nodes = @node.child_nodes
      else
        @nodes = [@node]
      end
    end
  end

  private
    def set_node
      @node = current_user.nodes.find(params[:id])
    end

    #def node_params
      #params.require(:node).permit(:name, :file, :parent_node_id)
    #end
end
