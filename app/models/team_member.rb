class TeamMember < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :user_id, presence: true
  validates :team_id, presence: true
  validates :is_leader, presence: true
end
