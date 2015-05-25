
#Author: Joseph Case
#This the first application I have built in Ruby so appologies if it's not perfect! It does in place feel a bit cluncky in places.

class PlanetModel

	#Constants
	ORIENTATIONS = {:N=>90,:E=>0,:S=>270,:W=>180 } 

	#Accessors
	def lastRobotPosition
		@aRobots[-1].position
	end

	def lostPoints
		return @aLostPoints
	end

	#... perhaps these could have used the coordinates class
	def gridMin_x
		return @iGridMin_x
	end

	def gridMin_y
		return @iGridMin_y
	end

	def gridMax_x
		return @iGridMax_x
	end

	def gridMax_y
		return @iGridMax_y
	end

	#Initialize
	def initialize

		@aRobots = []
		@aLostPoints = []

		makeGrid
		addRobot

	end

	#Methods
	def makeGrid 

		puts " "
		puts "Please enter grid size (x, y)"
		sGridSize = gets

		aGridsize = sGridSize.chomp.split(",")	

		if validateGridSize(aGridsize) then
			@iGridMin_x = 0
			@iGridMin_y = 0
			@iGridMax_x = aGridsize[0].to_i
			@iGridMax_y = aGridsize[1].to_i
		else
			puts "Enter valid coordinates!"
			makeGrid
		end

	end

	def addRobot
		puts ' ', 'Add Robot (x y orientation)'
		sPosition = gets
		aPosition = sPosition.chomp.split

		if validateRobotPlacement(aPosition) then
			# Here I'm passing the mars object to it's child. I'm sure there must be a better way to do this
			@aRobots.push(Robot.new(aPosition, self))
		end
		addRobot
	end

	def commandRobot(sCommands)
		@aRobots[-1].command(sCommands)
	end

	def addLostPoint(x, y)
		@aLostPoints.push(Coordinate.new(x, y))
	end

	#Validation Methods
	def validateGridSize(aGridsize)
		if aGridsize.length == 2 and
			aGridsize[0].to_i > 0 and 
			aGridsize[0].to_i <= 50 and 
			aGridsize[1].to_i > 0 and 
			aGridsize[1].to_i <= 50 then
			return true
		else
			return false
		end
	end

	def validateRobotPlacement(aPosition)
		if aPosition.length == 3 and
			!(/^[0-9]+$/ =~ aPosition[0]).nil? and
			!(/^[0-9]+$/ =~ aPosition[1]).nil? and
			aPosition[0].to_i <= @iGridMax_x and
			aPosition[1].to_i <= @iGridMax_y and
			ORIENTATIONS.has_key?(aPosition[2].to_sym) then
			return true
		else
			puts "Enter valid Robot position!"
			return false
		end
	end


end

class Robot

	#Robot Commands

	#Contants
	COMMANDS = {:F=>'forward', :R=>'right', :L=> 'left'} # This links commands to functions

	#Accessors
	def position
		return "#{@x} #{@y} #{PlanetModel::ORIENTATIONS.invert[@angle.abs % 360].to_s}#{if @lost == true then ' LOST' end}"	
	end

	#Initialize
	def initialize(aPosition, parent)
		@parent = parent
		@lost = false

		@x = aPosition[0].to_i
		@y = aPosition[1].to_i
		@angle = PlanetModel::ORIENTATIONS[aPosition[2].to_sym]

		commandRobot

		puts position

	end

	def commandRobot

		puts ' ', 'Enter robot commands'
		sCommands = gets.chomp

		if validateCommands(sCommands) then
			aCommands = sCommands.chars
			aCommands.each { 
				|command| 
				send(COMMANDS[command.to_sym])
				if @lost then break end
			}
		else
			commandRobot
		end		
	end

	#Commands - it would have maybe been nice to group these commands in some way
	def forward

		#Could use case statement here
		# case (@angle.abs % 360)
		# 	when 0 then x = @x + 1
		# 	etc...
		# end

		#Get new x
		x = @x + Math.cos(@angle * (Math::PI / 180)).round

		#Get new y
		y = @y + Math.sin(@angle * (Math::PI / 180)).round

		# This should perhaps be tested in the command method after each command
		if !isLostPoint(x, y) and !isLost(x, y) then
			@x = x
			@y = y
		end

	end

	def right
		@angle = @angle - 90
	end

	def left
		@angle = @angle + 90
	end

	#.. more commands can be added here and to the commands hash

	#Checks to see if the robot has moved onto a point where a previous robot has been lost
	def isLostPoint(x, y)
		@parent.lostPoints.each {
			|lostPoint|
			if lostPoint.x == x and lostPoint.y == y then
				return true
			end
		}
		return false
	end

	#Checks to see if the robot has moved off the grid
	def isLost(x, y)
		if x >= @parent.gridMin_x and x <= @parent.gridMax_x and y >= @parent.gridMin_y and y <= @parent.gridMax_y then
			return false
		else
			@parent.addLostPoint(x, y)
			@lost = true
			return true
		end
	end

	#Validation Methods
	def validateCommands(sCommands)

		#It would be nicer to get F L R from the COMMAND hash rather than re-listing them here
		if !(/^[F|L|R]{,49}$/ =~ sCommands).nil? then
			return true
		else
			puts "Enter valid command!"
			return false
		end
	end

end

class Coordinate

	#Accessors
	def x
		return @x
	end
	def y
		return @y
	end

	#Initialize
	def initialize(x, y)
		@x = x
		@y = y
	end

end

oMars = PlanetModel.new





