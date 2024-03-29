class User < ActiveRecord::Base
  has_paper_trail

  filterrific default_filter_params: {sorted_by: 'name_asc'},
              available_filters: %w[
                  sorted_by
                  search_query
                  with_role_name
                  with_team
              ]

  # will_paginate - numero de elementos por pagina
  self.per_page = 10

  BASIC_PROFILES = [
      Role::BASICO,
      Role::OPERACIONAL,
      Role::GESTOR,
      Role::ADMINISTRADOR
  ]

  REMAINING_ROLES = [
      Role::USER_UPDATE_ALL,
      Role::USER_DESTROY_ALL,
      Role::TEAM_CREATE,
      Role::TEAM_UPDATE_OWN,
      Role::TEAM_UPDATE_ALL,
      Role::TEAM_DESTROY_OWN,
      Role::TEAM_DESTROY_ALL,
      Role::GEO_ENTITY_REMOVE_OWN,
      Role::GEO_ENTITY_REMOVE_ALL,
      Role::GEO_ENTITY_CREATE,
      Role::TEAM_MEMBER_CREATE,
      Role::TEAM_MEMBER_DESTROY
  ]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # usar # em vez de > para for�ar as imagens a terem a resolu��o pretendida
  has_attached_file :avatar, styles: {medium: "300x300#", small: "175x175#", thumb: "75x75#"},
                    default_url: ActionController::Base.helpers.asset_path('teste.png'),
                    url: '/images/users/:id/:style/:basename.:extension',
                    path: ':rails_root/public/images/users/:id/:style/:basename.:extension'

  # Validate content type
  validates_attachment_content_type :avatar, content_type: /\Aimage/
  # Validate filename
  validates_attachment_file_name :avatar, matches: [/png\Z/, /jpe?g\Z/]

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :avatar, presence: true
  validates :profile, presence: true
  validates :email, presence: true, uniqueness: true
  validates_inclusion_of :profile, :in => BASIC_PROFILES

  # verifica a data limite aquando da chamada 'user.roles'
  # ou seja, apenas apresenta os papéis do utilizador que ainda nao tenham expirado
  has_many :user_roles_not_expired, -> { where "expiration_date > ?", Time.current },
           class_name: 'UserRole', foreign_key: 'user_id'

  has_many :user_roles, dependent: :delete_all
  has_many :geo_entities
  has_many :team_members, dependent: :delete_all

  has_many :teams, through: :team_members
  has_many :roles, through: :user_roles
  has_many :permissions, through: :roles

  has_many :teams_created, class_name: 'Team', foreign_key: 'created_by_user_id', dependent: :nullify
  has_many :leading_teams, class_name: 'Team', foreign_key: 'leader_id'
  has_many :teams_in_charge_of_location, class_name: 'Team', foreign_key: 'location_user_id'


  # o escopo para quando o utilizador insere uma pesquisa
  scope :search_query, lambda { |query|
    return nil if query.blank?
    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 2
    where(
        terms.map {
          or_clauses = [
              "LOWER(first_name) LIKE ?",
              "LOWER(last_name) LIKE ?"
          ].join(' OR ')
          "(#{ or_clauses })"
        }.join(' AND '),
        *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^created_at_/
        order("users.created_at #{ direction }")
      when /^name_/
        order("LOWER(users.first_name) #{ direction }, LOWER(users.last_name) #{ direction }")
      when /^profile_/
        order("LOWER(users.profile) #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_role_name, lambda { |role_names|
    where(profile: [*role_names])
  }

  scope :with_team, lambda { |team_ids|
    where("team_members.team_id = ?", [*team_ids]).joins(:team_members)
  }


  # This method provides select options for the `sorted_by` filter select input.
  # It is called in the controller as part of `initialize_filterrific`.
  def self.options_for_sorted_by
    [
        ['Nome (a-z)', 'name_asc'],
        ['Nome (z-a)', 'name_desc'],
        ['Data de registo (mais recente primeiro)', 'created_at_desc'],
        ['Data de registo (mais antigo primeiro)', 'created_at_asc'],
        ['Perfil (a-z)', 'profile_asc'],
        ['Perfil (z-a)', 'profile_desc']
    ]
  end

  # concatena o primeiro com o ultimo para as labels e afins
  def full_name
    "#{first_name} #{last_name}"
  end

  def get_user_teams_ids
    self.teams.map(&:id)
  end

  # user.get_user_temporary_roles.map(&:permissions).flatten devolve todas as permissões temporarias do user
  def get_user_temporary_roles
    self.user_roles.where("role_id > ? and expiration_date > ?", 4, Time.current)
  end

  # verifica se o perfil do utilizador é igual ao passado em parametro
  def is?(requested_profile)
    self.profile == requested_profile.to_s
  end
end
