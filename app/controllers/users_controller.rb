class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :check_params, :only => [:index]
  helper_method :default_column, :default_direction

  # GET /users
  # GET /users.json
  def index
    @users = User.where(params[:sort] + " <> ''").order(params[:sort] + " " + params[:direction]).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users, :except => [:email] }
    end
  end
  
  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.select('users.*').with_follows(current_user).find(params[:id])
    if request.path != user_path(@user)
      return redirect_to @user, :status => :moved_permanently
    end

    fix = 1
    data = @user.messages.select(['date(created_at) as date', 'count(id) as messages_count']).group('date')
    accumulation = 0
    @graph_messages = [[(@user.created_at.to_date-1+fix).to_time.to_i*1000, 0]] + data.map do |d|
      accumulation += d.messages_count
      [d.date.to_time.to_i*1000+fix, accumulation]
    end
    @graph_messages += [[(Time.now.to_date+fix).to_time.to_i*1000, accumulation]]

    data = @user.messages.select(['date(created_at) as date', 'sum(follows_count) as follows_sum']).where('follows_count > ?', 0).group('date')
    accumulation = 0
    @graph_follows = [[(@user.created_at.to_date-1+fix).to_time.to_i*1000, 0]] + data.map do |d|
      accumulation += d.follows_sum.to_i
      [(d.date+fix).to_time.to_i*1000, accumulation]
    end
    @graph_follows += [[(Time.now.to_date+fix).to_time.to_i*1000, accumulation]]

    @widgets_mode = true
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user, :except => [:email] }
    end
  end

  # PUT /users/1/bot
  def bot
    @user = User.find(params[:id])
    authorize! :bot, @user

    if params[:bot]
      @user.messages.delete_all
      @user.delete
    elsif params[:human]
      @user.update_column :human, true
    end

    t = Topic.find(params[:topic_id])
    t.touch

    respond_to do |format|
      format.html { redirect_to topic_url(t) }
      format.json { render json: @user, :except => [:email] }
    end
  end

  private

  def default_column
    'updated_at'
  end

  def default_direction column
    %w[topics_count messages_count updated_at].include?(column) ? 'desc' : 'asc'
  end

  def check_params
    params[:sort] = default_column unless User.column_names.include?(params[:sort])
    params[:direction] = default_direction(params[:sort]) unless %w[asc desc].include?(params[:direction])
  end

end
