class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def param( name, default )
    ( ! params.key?( name ) || params[ name ].nil? ) ? default : params[ name ]
  end
end
