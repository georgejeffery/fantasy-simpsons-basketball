class TeamsController < ApplicationController
  before_action :find_user
  before_action :find_team, only: %i[edit show mymatches]
  before_action :require_login

  def index
    @teams = Team.all
  end

  def new
    #authorized_for(params[:id])
    @team = Team.new
    @players = Player.all
  end

  def create
    @team = Team.create(team_params)
    redirect_to team_path(@team)
  end

  def show
    byebug
  end

  def edit
    authorized_for(params[:id])
    @players = @team.players
  end

  def mymatches
    @matches = @user.team.matches
  end

  private

  def find_team
    @team = Team.find_by(user_id: params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :user_id)
  end

  def find_user
    @user = User.find(session[:user_id])
  end
end
