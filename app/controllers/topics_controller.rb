class TopicsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :feed]

  # GET /topics
  # GET /topics.json
  def index
    @topics = Topic.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @topics }
    end
  end

  def feed
    @topic = Topic.includes(:user).find(params[:id])
    authorize! :read, @topic
    @messages = @topic.messages.includes(:user).order('messages.id desc').limit(10)

    respond_to do |format|
      format.rss { render :layout => false }
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @topic = Topic.select('topics.*').with_follows(current_user).find(params[:id])
    if request.path != topic_path(@topic)
      return redirect_to @topic, :status => :moved_permanently
    end
    authorize! :read, @topic

    if (params.has_key?(:newest) && m_id = current_user.bookmarks.where(topic_id: @topic.id).first.try(&:message_id)) || (m_id = params[:goto])
      nb = Message.where(topic_id: @topic.id).where('id <= ?', m_id).count
      page = (nb.to_f / Message::PER_PAGE).ceil
      return redirect_to topic_url(@topic, page: page > 1 ? page : nil, anchor: "m#{m_id}")
    end

    @messages = @topic.messages.select('messages.*').includes(:user, :updater, :small_messages => :user).with_follows(current_user).page params[:page]
    @message = Message.new topic_id: @topic.id

    if current_user
      b = current_user.bookmarks.find_or_initialize_by_topic_id(@topic.id)
      b.message_id = @topic.last_message_id
      b.save!
    end

    if current_user && current_user.id != @topic.viewer_id && @topic.last_page?(params[:page])
      @topic.update_column :viewer_id, current_user.id
      @topic.update_column :views_count, @topic.views_count+1
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.json
  def new
    @topic = Topic.new forum_id: params[:forum_id]
    @topic.messages.build
    authorize! :create, @topic

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.includes(:forum).find(params[:id])
    authorize! :update, @topic
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = Topic.new(params[:topic])
    @topic.user_id = current_user.id
    @topic.updater_id = current_user.id
    message = @topic.messages.first
    message.user_id = current_user.id
    authorize! :create, @topic

    respond_to do |format|
      if @topic.save
        format.html { redirect_to topic_url(@topic), notice: 'Topic was successfully created.' }
        format.json { render json: @topic, status: :created, location: @topic }
      else
        format.html { render action: "new" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1/pin
  def pin
    @topic = Topic.find(params[:id])
    authorize! :pin, @topic
    @topic.update_column :pinned, !@topic.pinned
    respond_to do |format|
      format.html { redirect_to forum_url(@topic.forum), notice: 'Topic was successfully updated.' }
      format.json { head :no_content }
    end
  end

  # PUT /topics/1
  # PUT /topics/1.json
  def update
    params[:topic].delete :messages_attributes
    @topic = Topic.find(params[:id])
    authorize! :update, @topic

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { redirect_to topic_url(@topic), notice: 'Topic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic = Topic.find(params[:id])
    authorize! :destroy, @topic
    forum = @topic.forum
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to forum_url(forum) }
      format.json { head :no_content }
    end
  end
end
