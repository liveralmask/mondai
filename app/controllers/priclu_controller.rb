class PricluController < ApplicationController
	class Input
		attr_accessor	:n, :m
		
		def initialize
			@max_n	= 100000
			@max_m	= 100000
		end
		
		def n=( n )
			n = @max_n if @max_n <= n
			@n = n
		end
		
		def m=( m )
			m = @max_m if @max_m <= m
			@m = m
		end
	end
	
	def index
		@title = "プリクラ#{@title}"
		
		input = get_param( "input", {
			"n"	=> "7",
			"m"	=> "5"
		} )
		
		@input = Input.new
		@input.n	= input[ "n" ].to_i
		@input.m	= input[ "m" ].to_i
		
		targets = @input.n.times.collect{|i| { :no => i + 1, :members => [] } }
		fixed_members = []
		@start_time = Time.now
		result = Benchmark.realtime do
			while 0 < targets.length
				members = get_members( targets, @input.m )
				
				fixed_members.push members
				
				add_members( targets, members, @input.n )
			end
		end
		
		@result = {
			:realtime		=> result,
			:fixed_members	=> fixed_members
		}
	end
	
protected
	def get_members( targets, num )
		members = [ targets.shift ]
		
		targets.length.times{
			puts (Time.now - @start_time)
			
			target = targets.shift
			
			if members[ 0 ][ :members ].include?( target[ :no ] )
				targets.push target
				next
			end
			
			members.push target
			break if num == members.length
		}
		
		if members.length < num
			targets.length.times{
				members.push targets.shift
				break if num == members.length
			}
		end
		
		members
	end
	
	def add_member( target, members )
		members.each{|member|
			target[ :members ].push member[ :no ] if ! target[ :members ].include?( member[ :no ] )
		}
	end
	
	def add_members( targets, members, max )
		members.each{|member|
			add_member( member, members )
			
			# 全メンバーと組んでいないメンバーを対象に戻す
			targets.push member if member[ :members ].length < max
		}
	end
end
