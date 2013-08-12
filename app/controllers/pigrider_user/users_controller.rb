require_dependency "pigrider_user/application_controller"

module PigriderUser
  class UsersController < ApplicationController
    include SessionsHelper
    
  
    before_filter :notSignedIn, :only=>[:edit,:update,:show,:destroy]
    before_filter :notPigRiderAdministrator, :only=>[:manageAllUsers]
    

    ##################################################  
    private      # Below are private methods.
    ##################################################
    
    def notSignedIn
      if !userSignedIn
        redirect_to pigrider_user.signInUser_path
      end
    end
    
    
    def notPigRiderAdministrator
      if !isAdministrator
        redirect_to pigrider_user.signInUser_path
      end
    end
    
    
    def answerPigRiderQuestionsCorrectly(sQuestionOneAnswer,sQuestionTwoAnswer)
      sAnswerHash="$2a$10$z9mQZQ9EO1tJMrbib8Ys7.hKpKVMFYL8CGkhpRYz9ifv6ZPhUXXSq"
      oQuestionOneCorrectAnswer=BCrypt::Password.new(sAnswerHash)
      sAnswerHash="$2a$10$0ooXmrifcaSG65SYXVssc.8OU.X6oMrJ32gVXuTwuCgaMQ/juCZ5W"
      oQuestionTwoCorrectAnswerForPigRiderDeveloper=BCrypt::Password.new(sAnswerHash)
      sAnswerHash="$2a$10$WFeqxZN7DPiWRecJrlHJK.8LCCit5N0NkedGBTEBo8CUgsdEq.7eG"
      oQuestionTwoCorrectAnswerForPigRiderAdmin=BCrypt::Password.new(sAnswerHash)
      
      if oQuestionOneCorrectAnswer==sQuestionOneAnswer 
        if oQuestionTwoCorrectAnswerForPigRiderDeveloper==sQuestionTwoAnswer
          return $sPigRiderDeveloper
        elsif oQuestionTwoCorrectAnswerForPigRiderAdmin==sQuestionTwoAnswer
          return $sPigRiderAdministrator
        else
          return ""
        end
      else
        return ""
      end
    end
    
  
    ##################################################  
    public      # Below are public methods.
    ##################################################
      
    def manageAllUsers
      @dAllUsers=User.all
    end
  
  
    def create
      @dUser=User.new
      @dUser.username=params[:user][:username]
      @dUser.email=params[:user][:email]
  
      @dUser.authorityLevel=answerPigRiderQuestionsCorrectly(params[:user][:questionOne],params[:user][:questionTwo])
      if @dUser.authorityLevel!=""
        @dUser.password=params[:user][:password]
        @dUser.password_confirmation=params[:user][:password_confirmation]
        
        if @dUser.save
          memorizeUser(@dUser.username,@dUser.id,@dUser.authorityLevel)
          redirect_to pigrider_user.showUser_path(@dUser.id)
        else
          render 'new'
        end
      else
        @dUser.errors["RegistryQuestions"]="You didn't answer both questions correctly!"
        render 'new'
      end
    end
    
    
    def destroy
      # Use 'transaction' to improve sql operation speed, because this makes all sql operations in one transaction.
      ActiveRecord::Base.transaction do
        @dUser=User.find(params[:id])
        
        if !@dUser.authenticate(params[:deleteUser][:password])
          if !isAdministrator || !User.find(session[:iRememberedUserid]).authenticate(params[:deleteUser][:password])
            @dUser.errors["Password"]="Password is not correct!"
            render 'edit'
            return
          end
        end
        
        signOutUser(@dUser.username)
        @dUser.destroy
        redirect_to pigrider_user.manageAllUsers_path
      end
    end
    
    
    def edit
      @dUser=User.find(params[:id])
    end
  
  
    def forgetPassword
      @dUser=User.new
    end
  
  
    def new
      @dUser=User.new
    end
  
  
    def show
      @dUser=User.find(params[:id])
    end
    
    
    def update
      # Use 'transaction' to improve sql operation speed, because this makes all sql operations in one transaction.
      ActiveRecord::Base.transaction do
        @dUser=User.find(params[:id])
        
        if !params[:changePassword].nil?
          if !@dUser.authenticate(params[:changePassword][:old_password])
            if !isAdministrator || !User.find(session[:iRememberedUserid]).authenticate(params[:changePassword][:old_password])
              @dUser.errors["Password"]="Password is not correct!"
              render 'edit'
              return
            end
          end
          
          @dUser.password=params[:changePassword][:password]
          @dUser.password_confirmation=params[:changePassword][:password_confirmation]
          if @dUser.save
            redirect_to pigrider_user.showUser_path(@dUser.id,:sMessage=>"Successfully changed the password!")
          else
            render 'edit'
            return
          end
        end
        
        if !params[:changeEmail].nil?
          @dUser.email=params[:changeEmail][:email]
          
          if !@dUser.authenticate(params[:changeEmail][:password])       
            if !isAdministrator || !User.find(session[:iRememberedUserid]).authenticate(params[:changeEmail][:password])
              @dUser.errors["Password"]="Password is not correct!"
              render 'edit'
              return
            end
          end
            
          @dUser.password="FakeMimaForValidation!"
          @dUser.password_confirmation=@dUser.password
          if @dUser.valid?
            User.where(:id=>@dUser.id).update_all(:email=>@dUser.email)
            redirect_to pigrider_user.showUser_path(@dUser.id,:sMessage=>"Successfully changed the email!")
          else
            render 'edit'
            return
          end
        end
        
        if isAdministrator && !params[:changeAuthorityLevel].nil?
          @dUser.authorityLevel=params[:changeAuthorityLevel][:authorityLevel]
          
          if User.find(session[:iRememberedUserid]).authenticate(params[:changeAuthorityLevel][:password])
            @dUser.password="FakeMimaForValidation!"
            @dUser.password_confirmation=@dUser.password
            if @dUser.valid?
              User.where(:id=>@dUser.id).update_all(:authorityLevel=>@dUser.authorityLevel)
              redirect_to pigrider_user.showUser_path(@dUser.id,:sMessage=>"Successfully changed the authority level!")
            else
              render 'edit'
              return
            end
          else
            @dUser.errors["Password"]="PigRider administrator's password is not correct!"
            render 'edit'
            return
          end
        end
      end
    end
    
    
    def updateFogottenPassword
      # Use 'transaction' to improve sql operation speed, because this makes all sql operations in one transaction.
      ActiveRecord::Base.transaction do
        sAuthorityLevel=answerPigRiderQuestionsCorrectly(params[:forgetPassword][:questionOne],params[:forgetPassword][:questionTwo])
        
        if sAuthorityLevel==''
          @dUser=User.new
          @dUser.username=params[:forgetPassword][:username]
          @dUser.errors["RegistryQuestions"]="You didn't answer both questions correctly!!"
          render 'forgetPassword'
          return
        else      
          @dUser=User.find_by_username(params[:forgetPassword][:username])
          if @dUser.nil?
            @dUser=User.new
            @dUser.username=params[:forgetPassword][:username]
            @dUser.errors["NotFoundUsername"]="Username is not correct!"
            render 'forgetPassword'
            return
          else
            if sAuthorityLevel==@dUser.authorityLevel || sAuthorityLevel==$sPigRiderAdministrator
              @dUser.password=params[:forgetPassword][:password]
              @dUser.password_confirmation=params[:forgetPassword][:password_confirmation]
              if @dUser.save
                memorizeUser(@dUser.username,@dUser.id,@dUser.authorityLevel)
                redirect_to pigrider_user.showUser_path(@dUser.id,:sMessage=>"Successfully changed the password!")
              else
                render 'forgetPassword'
                return
              end
            else
              @dUser.username=params[:forgetPassword][:username]
              @dUser.errors["RegistryQuestions"]="You didn't answer both questions correctly!!"
              render 'forgetPassword'
              return
            end
          end
        end
      end
    end

  end
end
