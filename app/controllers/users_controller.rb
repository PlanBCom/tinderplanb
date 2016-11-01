class UsersController < ApplicationController

  before_action :require_login, except: :deads
  before_action :set_user, only: [:edit, :profile, :update, :destroy, :get_email, :matches]

  def index
      if params[:id]
        @users = User.gender(current_user).not_me(current_user).where('id < ?', params[:id]).limit(10) - current_user.matches(current_user)
      else
        @users = User.gender(current_user).not_me(current_user).limit(10) - current_user.matches(current_user)
      end

      respond_to do |format|
        format.html
        format.js
      end

  end

  def deads
    @results = ActiveRecord::Base.connection.execute("

    select sum(votos) as votos,
      (select name from users where id = user_id) as name
    from (
      select count(*) as votos, user_id from friendships where State = 'ACTIVE' group by user_id
      union all
      select count(*) as votos, friend_id as user_id from friendships group by friend_id
    ) as A group by user_id order by 1 desc")

    # raise results.to_json
  end

  def edit
    authorize! :update, @user
  end

  def update
    if @user.update(users_params)
      respond_to do |format|
        format.html { redirect_to users_path}
      end
    else
      redirect_to edit_user_path(@user)
    end
  end

  def destroy

    if @user.destroy
      session[:user_id] = nil
      session[:omniauth] = nil
      redirect_to root_path
    else
      redirect_to edit_user_path(@user)
    end

  end

  def profile
  end

  def matches
    authorize! :read, @user
    @matches = current_user.friendships.where(state: "ACTIVE").map(&:friend) + current_user.inverse_friendships.where(state: "ACTIVE").map(&:user)
  end


  def get_email
    respond_to do |format|
      format.js
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def users_params
    params.require(:user).permit(:interest, :bio, :avatar, :location, :date_of_birth)
  end

end
