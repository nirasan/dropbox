class NodesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_node,
    only: [:new_file, :new_folder, :list, :show, :edit, :update, :destroy, :download, :copy, :move_folder_list, :move]

  def index
    redirect_to list_node_path(current_user.root_node)
  end

  def show
  end

  # フォルダ配下のファイル一覧
  def list
    @nodes = @node.child_nodes.sort_by(params['sort'])
  end

  def search
    @nodes = current_user.nodes.where('name LIKE ?', "%#{params['search']}%")
  end

  def new
    @node = Node.new
  end

  def new_file
  end

  def new_folder
  end

  def edit
  end

  def create
    @node = current_user.nodes.build(params.require(:node).permit(:name, :file, :parent_node_id))
    @node.set_file_or_folder
    respond_to do |format|
      if @node.save
        format.html { redirect_to list_node_path(@node.parent_node), notice: 'Node was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @node.update(params.require(:node).permit(:name))
        format.html { redirect_to list_node_path(@node.parent_node), notice: 'Node was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @node.destroy
    respond_to do |format|
      format.html { redirect_to list_node_path(@node.parent_node), notice: 'Node was successfully destroyed.' }
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
        format.html { redirect_to list_node_path(@node.parent_node), notice: 'Node was successfully copied.' }
      else
        format.html { redirect_to list_node_path(@node.parent_node), alert: 'Node was unsuccessfully copied.' }
      end
    end
  end

  def move_folder_list
    @tree = Node.get_folder_tree(current_user)
  end

  def move
    respond_to do |format|
      if @node.move_to(params['node_id'])
        format.html { redirect_to list_node_path(@node.parent_node), notice: 'Node was successfully moved.' }
      else
        format.html { redirect_to list_node_path(@node.parent_node), alert: 'Node was unsuccessfully moved.' }
      end
    end
  end

  private
    def set_node
      @node = current_user.nodes.find(params[:id])
    end

end
