class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all.paginate(page: params[:page], per_page: 10).order('created_at DESC')
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created. #{make_undo_link}" }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated. #{make_undo_link}" }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def history
    @versions = PaperTrail::Version.paginate(page: params[:page], per_page: 10).order('created_at DESC')
  end

  def undo
    @post_version = PaperTrail::Version.find_by_id(params[:id])

    begin
      if @post_version.reify
        @post_version.reify.save
      else
        # For undoing the create action
        @post_version.item.destroy
      end
      flash[:success] = "Undid that! #{make_redo_link}"
    rescue
      flash[:alert] = "Failed to undo the action."
    ensure
      redirect_to root_path
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed. #{make_undo_link}" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :body)
    end

  def make_undo_link
    view_context.link_to 'Undo that plz!', undo_path(@post.versions.last), method: :post
  end

  def make_redo_link
    params[:redo] == "true" ? link = "Undo that plz!" : link = "Redo that plz!"
    view_context.link_to link, undo_path(@post_version.next, redo: !params[:redo]), method: :post
  end
end
