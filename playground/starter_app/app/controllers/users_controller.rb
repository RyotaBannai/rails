class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy] # before_actin [method name], [options]
  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show] # basic authentication
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    # OPTIMIZE 
    #console # show console on the browser
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  # POST /users
  # POST /users.json
  def create
    # puts params.inspect # show request on terminal
    # Rails.logger.debug params.inspect # this is the better way.
    # <%= params.inspect %> in erb

    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html do
          redirect_to @user, notice: 'User was successfully created.'
        end
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    # puts params.to_yaml 
    #byebug
    respond_to do |format|
      if @user.update(user_params)
        @user.avatar.attach(user_params[:avatar]) if user_params.has_key?(:avatar) # if there is no if conditional, this updates data even when param has no avatar key
        format.html do
          redirect_to @user, notice: 'User was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html do
        redirect_to users_url, notice: 'User was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # エラーメッセージを隠す
  def record_not_found
    render plain: "404 Not Found", status: 404
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end
  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end
end
