class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  belongs_to :group
  validates :username, length: {minimum: 3}

  def admin?
    admin
  end

  def first_name
    # `username` might be nil, so convert to string
    # match everything (non-whitespace) at the start, up to the first space
    username.to_s.match(/^(\S+)/) { |m| m[1] } || username.truncate(9)
  end
end
