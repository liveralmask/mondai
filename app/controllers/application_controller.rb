require "benchmark"

class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	
	def initialize
		super
		
		@title = "問題"
	end
	
	def get_param( name, default_value )
		return default_value if ! params.key?( name ) || params[ name ].nil?
		
		params[ name ]
	end
end
