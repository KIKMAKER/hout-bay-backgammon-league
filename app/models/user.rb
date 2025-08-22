class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  belongs_to :group, optional: true
  validates :username, length: { minimum: 3 }
  # Matches where the user is player 1
  has_many :matches_as_player1,
           class_name:  "Match",
           foreign_key: :player1_id,
           dependent:   :destroy

  # Matches where the user is player 2
  has_many :matches_as_player2,
           class_name:  "Match",
           foreign_key: :player2_id,
           dependent:   :destroy

  has_many :matches, ->(u) {
    where("player1_id = :id OR player2_id = :id", id: u.id)
  }, class_name: "Match"

  
  # Convenience: all matches involving this user
  def matches
    Match.where("player1_id = :id OR player2_id = :id", id: id)
  end

  def admin?
    admin
  end

  def first_name
    # `username` might be nil, so convert to string
    # match everything (non-whitespace) at the start, up to the first space
    username.to_s.match(/^(\S+)/) { |m| m[1] } || username.truncate(9)
  end
end
