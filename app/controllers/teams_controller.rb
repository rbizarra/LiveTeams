class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :set_all_users, only: [:new, :edit]

  layout "listings"

  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
  end

  # GET /teams/new
  def new
    @team = Team.new
    @users_in_team = @team.users
  end

  # GET /teams/1/edit
  def edit
    @users_in_team = @team.users


    # puts @team.team_members.inspect
    @team_leader = TeamMember.find_by(team_id: @team.id, is_leader: true)
    puts @team_leader.nil?

  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save

        # adicionar os v�rios membros da equipa, colocar aqui um FOR!
        # todos os elementos sao adicionados como nao sendo lider
        params[:team][:users].each do |u_id|
          puts "LOOOOOOOOOOOOOOOL"

          puts u_id
          puts params[:team][:id]

          puts "LEADER LEADER LEADER LEADER"

          puts params[:team][:is_leader]

          # � o lider, adiciona-se com o parametro a true
          if u_id == params[:team][:is_leader]
            team_member = TeamMember.new(:user_id => u_id, :team_id => @team.id, :is_leader => true)
          else
            team_member = TeamMember.new(:user_id => u_id, :team_id => @team.id, :is_leader => false)
          end
          team_member.save
        end

        format.html { redirect_to @team, notice: 'Team was successfully created.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    users_in_team = @team.users

    # array com os ids de todos os elementos que ja estavam na equipa
    users_id = users_in_team.ids

    respond_to do |format|
      if @team.update(team_params)

        # come�amos por remover todas as entradas da tabela para esta equipa
        TeamMember.delete_all(["team_id = ?", @team.id.to_s])

        params[:team][:users].each do |u_id|

          if u_id == params[:team][:is_leader]
            team_member = TeamMember.new(:user_id => u_id, :team_id => @team.id, :is_leader => true)
          else
            team_member = TeamMember.new(:user_id => u_id, :team_id => @team.id, :is_leader => false)
          end
          team_member.save



          # if !(users_id.include? u_id.to_i)
          #   puts u_id
          #   team_member = TeamMember.new(:user_id => u_id, :team_id => @team.id, :is_leader => false)
          #   team_member.save
          # else
          #   users_id.delete(u_id.to_i)
          # end
        end















        # se nao for passado nenhum user como parametro, � porque nenhum esta seleccionado
        # e assim s�o removidos todos os elementos desta equipa
        # if !params[:team][:users].nil?
        #
        #   # percorre todos os elementos passados como parametro
        #   # se o parametro nao estiver em users_id, cria-se uma nova entrada na tabela TeamMembers
        #   # se estiver em users_id, o mesmo id � removido do array.
        #   # todos os ids que estiverem no array no final do ciclo sao removidos da tabela de membros
        #   params[:team][:users].each do |u_id|
        #     if !(users_id.include? u_id.to_i)
        #       puts u_id
        #       team_member = TeamMember.new(:user_id => u_id, :team_id => @team.id, :is_leader => false)
        #       team_member.save
        #     else
        #       users_id.delete(u_id.to_i)
        #     end
        #   end
        #
        #   puts users_id.count
        #
        #   # se ainda estiver algum id em users_id, essas entradas sao removidas da tabela de membros
        #   users_id.each do |u_id|
        #     TeamMember.delete_all(["user_id = ? AND team_id = ?", u_id.to_s, @team.id.to_s])
        #   end
        # else
        #   TeamMember.delete_all(["team_id = ?", @team.id.to_s])
        # end

        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to teams_url, notice: 'Team was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.find(params[:id])
  end

  def set_all_users
    @all_users = User.all.order(id: :asc)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def team_params
    params.require(:team).permit(:name, :latlon, :is_leader, users: [:id])
  end
end