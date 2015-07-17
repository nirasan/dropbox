class NodesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_node, only: [:list, :show, :edit, :update, :destroy]

  def index
    redirect_to list_node_path(current_user.root_node)
  end

  def show
  end

  # フォルダ配下のファイル一覧
  def list
  end

  def new
    @node = Node.new
  end

  def edit
  end

  def create
    @node = current_user.nodes.build(params.require(:node).permit(:name, :file, :parent_node_id))
    @node.is_root = false
    if @node.file.nil?
      @node.name = @node.file.file.filename
      @node.is_folder = false
    else
      @node.is_folder = true
    end

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
      format.html { redirect_to nodes_url, notice: 'Node was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_node
      @node = current_user.nodes.find(params[:id])
    end

end
