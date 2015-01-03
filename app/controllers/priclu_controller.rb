class PricluController < ApplicationController
	class Input
		attr_accessor	:n, :m
		
		def initialize
			@max_n	= 10000
			@max_m	= 10000
		end
		
		def n=( n )
			if @max_n <= n
				n = @max_n
			elsif n <= 0
				n = 1
			end
			
			@n = n
		end
		
		def m=( m )
			if @max_m <= m
				m = @max_m
			elsif m <= 0
				m = 1
			end
			
			@m = m
		end
	end
	
	def index
		@title = "プリクラ#{@title}"
		
		@max_count	= 10000
		@max_sec	= 10
		
		input = get_param( "input", {
			"n"	=> "7",
			"m"	=> "5"
		} )
		
		@input = Input.new
		@input.n	= input[ "n" ].to_i
		@input.m	= input[ "m" ].to_i
		
		targets = @input.n.times.collect{|i| { :no => i + 1, :members => {} } }
		fixed_members = []
		error = nil
		@start_time = Time.now
		result = Benchmark.realtime do
			while 0 < targets.length
				if @max_sec <= ( Time.now - @start_time )
					error = "#{@max_sec}秒オーバー"
					break
				end
				
				members = get_members( targets, @input.m )
				
				fixed_members.push members
				if @max_count <= fixed_members.length
					error = "#{@max_count}回オーバー"
					break
				end
				
				add_members( targets, members, @input.n )
			end
		end
		
		@result = {
			:realtime		=> result,
			:fixed_members	=> fixed_members,
			:error			=> error
		}
	end
	
protected
	def get_members( targets, num )
		members = [ targets.shift ]
		
		targets.length.times{
			target = targets.shift
			
			if members[ 0 ][ :members ].key?( target[ :no ] )
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
			target[ :members ][ member[ :no ] ] = true if ! target[ :members ].key?( member[ :no ] )
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
