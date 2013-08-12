module PigriderUser
  module SessionsHelper
    $sPigRiderDeveloper="PigRider Developer"
    $sPigRiderAdministrator="PigRider Administrator"  
    
    
    def memorizeUser(sUsername,iUserid,sAuthorityLevel)
      session[:sRememberedUsername]=sUsername
      session[:iRememberedUserid]=iUserid
      session[:bAdministrator]=(sAuthorityLevel==$sPigRiderAdministrator)
      session[:bPiRiderDeveloper]=(session[:bAdministrator] || sAuthorityLevel==$sPigRiderDeveloper)
    end
    
    
    def signOutUser(sUsername=nil)
      if !sUsername.nil?
        if session[:sRememberedUsername]!=sUsername
          return
        end
      end
      session.delete(:sRememberedUsername)
      session.delete(:iRememberedUserid)
      session.delete(:bAdministrator)
      session.delete(:bPiRiderDeveloper)
    end
    
     
    def usernameForSignedInUser
      return session[:sRememberedUsername]
    end
    
    
    def useridForSignedInUser
      return session[:iRememberedUserid]
    end
    
    
    def userSignedIn(iUserid=nil)
      if iUserid.nil?
        return !session[:sRememberedUsername].nil?
      else
        return !session[:sRememberedUsername].nil? && session[:iRememberedUserid]==iUserid
      end
    end
    
    
    def isAdministrator
      return session[:bAdministrator]
    end
    
    
    def isPiRiderDeveloper
      return session[:bPiRiderDeveloper]
    end
  end
end
