class NodesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_node, only: [:show, :edit, :update, :destroy]

  #TODO /hodes/#{root_node.id}/show へリダイレクト
  def index
    @nodes = current_user.nodes.all
  end

  #TODO フォルダ配下のファイル一覧
  def show
  end

  def new
    @node = Node.new
  end

  def edit
  end

  def create
    @node = current_user.nodes.build(params.require(:node).permit(:name, :file))
    @node.is_root = false
    if @node.file.nil?
      @node.name = @node.file.file.filename
      @node.is_folder = false
    else
      @node.is_folder = true
    end

    respond_to do |format|
      if @node.save
        format.html { redirect_to @node, notice: 'Node was successfully created.' }
        format.json { render :show, status: :created, location: @node }
      else
        format.html { render :new }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @node.update(node_params)
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { render :show, status: :ok, location: @node }
      else
        format.html { render :edit }
        format.json { render json: @node.errors, status: :unprocessable_entity }
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

    def node_params
      params[:node]
    end
end
