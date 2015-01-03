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
		@title		= "プリクラ#{@title}"
		@version	= "2"
		
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
			if @input.m <= 1
				targets.each{|target|
					fixed_members.push [ target ]
				}
			elsif @input.n <= @input.m
				fixed_members.push targets
			else
				# 最初のメンバーと全メンバーを組み合わせ、最初のメンバーを対象外にする
				first_member = targets.shift
				targets.each_slice( @input.m - 1 ).to_a.each{|members|
					members.unshift( first_member )
					( @input.m - members.length ).times{|i|
						members.push targets[ i ]
					}
					
					fixed_members.push members
					add_members( targets, members, @input.n )
				}
				
				while 0 < targets.length
					if @max_sec <= ( Time.now - @start_time )
						error = "#{@max_sec}秒オーバー"
						break
					elsif @max_count <= fixed_members.length
						error = "#{@max_count}回オーバー"
						break
					end
					
					members = get_members( targets, @input.m )
					
					fixed_members.push members
					
					add_members( targets, members, @input.n )
				end
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
		members = []
		
		if targets.length <= num
			targets.each{|target|
				members.push target
			}
		else
			indexes = []
			targets.length.times{|i|
				target = targets[ i ]
				
				members.each{|member|
					if member[ :members ].key?( target[ :no ] )
						indexes.push i
						target = nil
						break
					end
				}
				next if target.nil?
				
				members.push target
				break if num == members.length
			}
			
			( num - members.length ).times{|i|
				members.push targets[ indexes[ i ] ]
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
			
			# 全メンバーと組んだメンバーを対象から外す
			targets.delete( member ) if member[ :members ].length == max
		}
	end
end
