module PigriderUser
  class User < ActiveRecord::Base
    establish_connection "pigrider_user_#{Rails.env}"

    attr_accessible :authorityLevel, :email, :password, :password_confirmation, :username
    has_secure_password

    validates :username, length:{minimum:5,maximum:50,message:"The length of Username should be between 5 and 50 characters."}
    validates_uniqueness_of :username, message:"This username has already been registered."
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, format:{with:VALID_EMAIL_REGEX,message:"Email address is invalid."}
    validates :password, length:{minimum:8,maximum:50,message:"The length of Password should be between 8 and 50 characters."}
    validates :password_confirmation, presence:{message:"The Password Confirmation cannot be empty."}
  end
end
