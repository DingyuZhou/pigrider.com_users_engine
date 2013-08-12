PigriderUser::Engine.routes.draw do
  
  # sessions  
  get "/signIn"=>"sessions#new", :as=>:signInUser
  get "/signOut"=>"sessions#destroy", :as=>:signOutUser
  post "/createSession"=>"sessions#create", :as=>:createSession


  # users
  get "/edit/:id"=>"users#edit", :as=>:editUser
  get "/forgetPassword"=>"users#forgetPassword", :as=>:forgetPassword
  get "/manageAllUsers"=>"users#manageAllUsers", :as=>:manageAllUsers
  get "/new"=>"users#new", :as=>:newUser
  get "/show/:id"=>"users#show", :as=>:showUser
  post "/create"=>"users#create", :as=>:createUser
  post "/destroy/:id"=>"users#destroy", :as=>:destroyUser  
  post "/update/:id"=>"users#update", :as=>:updateUser
  post "/updateForgottenPassword"=>"users#updateFogottenPassword", :as=>:updateFogottenPassword

end
