require_dependency "pigrider_user/application_controller"

module PigriderUser
  class SessionsController < ApplicationController
    include SessionsHelper
    
    
    def new
      if userSignedIn
        redirect_to pigrider_user.showUser_path(session[:iRememberedUserid])
        return
      end
      @dUser=User.new
    end
    
    
    def create
      @dUser=User.find_by_username(params[:session][:username])
      if @dUser 
        if @dUser.authenticate(params[:session][:password])
          memorizeUser(@dUser.username,@dUser.id,@dUser.authorityLevel)
          redirect_to pigrider_user.showUser_path(@dUser.id)
        else
          @dUser.errors["Password"]="Password is not correct!"
          render 'new'
        end 
      else
        @dUser=User.new
        @dUser.username=params[:session][:username]
        @dUser.errors["Username"]="Username is not found!"
        render 'new'
      end
    end
  
  
    def destroy
      signOutUser
      redirect_to main_app.root_path
    end
  end
end
