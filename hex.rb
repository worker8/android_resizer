require 'byebug'
@directory_name = "converted_assets"
  @set = []
  @set[0] = [144, 96, 72, 48, 36]
  @set[1] = [126, 84, 64, 42, 32]
  @set[2] = [96, 64, 48, 32, 24]
  @set[3] = [72, 48, 36, 24, 18]
  @set[4] = [72, 48, 36, 24, 18]
  @set[5] = [66, 44, 33, 22, 16]
  @set[6] = [162, 108, 80, 54, 40]
  @set[7] = [282, 188.0, 141.0, 94.0, 70.5]
  @default_set = @set[2]
def check_if_valid_image_path?(image_path)
  puts "imagepath: #{image_path}"
  image_path.gsub!(/\s+/, "")
  result = `ls #{image_path}`
  if result.empty?
    return false
  else
    return true
  end
end

def print_help(help_arg)
  if !help_arg.nil? && help_arg == "set"
    puts "-set usage:"
    puts "[syntax]"
    puts "  ruby hex.rb <source> -set <group>"
    puts "  <group> can be the following:"
    #set.each_with_index {|item,index|
    #puts "#{index}: #{item}"
    #}
    puts "  0: launcher icon 1 [144, 96, 72, 48, 36]"
    puts "  1: launcher icon 2 [126, 84, 64, 42, 32]"
    puts "  2: actionbar, tab icon 1 [96, 64, 48, 32, 24]"
    puts "  3: actionbar, tab icon 2 [72, 48, 36, 24, 18]"
    puts "  4: notification icon 1 [72, 48, 36, 24, 18]"
    puts "  5: notification icon 2 [66, 44, 33, 22, 16]"
    puts "  6: custom size [162, 108, 80, 54, 40]"
  else
    # general help
    puts "General Usage: "
    puts "  ruby hex.rb -help or -h: printing this help instruction"
    puts "  ruby hex.rb <source> -set a: type 'ruby hex.rb -help set' for more info"
    puts "  ruby hex.rb -calculate 123 <---- 123 should be the xxhdpi size, it will return you the rest of the sizes for xhdpi, hdpi, mdpi, ldpi"
    puts "  ruby hex.rb <source> -resize "
  end
end

def convert_image(set_group)
  mkdir_command = "mkdir #{@directory_name}"
  mkdir_command_ldpi = "cd #{@directory_name} && mkdir drawable-ldpi"
  mkdir_command_mdpi = "cd #{@directory_name} && mkdir drawable-mdpi"
  mkdir_command_hdpi = "cd #{@directory_name} && mkdir drawable-hdpi"
  mkdir_command_xhdpi = "cd #{@directory_name} && mkdir drawable-xhdpi"
  mkdir_command_xxhdpi = "cd #{@directory_name} && mkdir drawable-xxhdpi"

  mkdir_result = []
  mkdir_result[0] = system(mkdir_command)
  mkdir_result[1] = system(mkdir_command_ldpi)
  mkdir_result[2] = system(mkdir_command_mdpi)
  mkdir_result[3] = system(mkdir_command_hdpi)
  mkdir_result[4] = system(mkdir_command_xhdpi)
  mkdir_result[5] = system(mkdir_command_xxhdpi)
  all_pass = true
  mkdir_result.each{ |res|
    if !mkdir_result
      all_pass = false
      break;
    end
  }
  if all_pass
    convert_commands = []
    convert_commands.push "convert #{@image_path} -resize #{set_group[0]}x#{set_group[0]} #{@directory_name}/drawable-xxhdpi/#{@image_name}"
    convert_commands.push "convert #{@image_path} -resize #{set_group[1]}x#{set_group[1]} #{@directory_name}/drawable-xhdpi/#{@image_name}"
    convert_commands.push "convert #{@image_path} -resize #{set_group[2]}x#{set_group[2]} #{@directory_name}/drawable-hdpi/#{@image_name}"
    convert_commands.push "convert #{@image_path} -resize #{set_group[3]}x#{set_group[3]} #{@directory_name}/drawable-mdpi/#{@image_name}"
    convert_commands.push "convert #{@image_path} -resize #{set_group[4]}x#{set_group[4]} #{@directory_name}/drawable-ldpi/#{@image_name}"
    convert_commands.each { |a|
    puts "#{a}"
    system(a)
    }
  end
end

def resize_by_percentage
  path = @image_path.split '/'
  @image_name = path.last
  path = path.take(path.size - 2)
  path = path.join '/'

  # construct commands
  convert_commands = []
  convert_commands.push "convert #{@image_path} -resize  #{Calculator.dpi_divider_percentage_hash[:xhdpi]} #{path}/drawable-xhdpi/#{@image_name}"
  convert_commands.push "convert #{@image_path} -resize  #{Calculator.dpi_divider_percentage_hash[:hdpi]} #{path}/drawable-hdpi/#{@image_name}"
  convert_commands.push "convert #{@image_path} -resize  #{Calculator.dpi_divider_percentage_hash[:mdpi]} #{path}/drawable-mdpi/#{@image_name}"
  convert_commands.push "convert #{@image_path} -resize  #{Calculator.dpi_divider_percentage_hash[:ldpi]} #{path}/drawable-ldpi/#{@image_name}"

  # run commands
  convert_commands.each { |command|
    puts "#{command}"
    system(command)
  }
  #end
end

def get_set_group(set_arg)
  if set_arg.nil? || set_arg.to_i >= @set.length || set_arg.to_i < 0
    #puts "Invalid set argument, type 'ruby hex.rb -help set' to learn more about the usage"
    puts "No valid set argument detected, use default set argument :#{@default_set}"
    return @default_set
  else
    return @set[set_arg.to_i]
  end
end

class Calculator
  @@dpi_divider_hash = {:xxhdpi => 1, :xhdpi => 1.5, :hdpi => 2.0, :mdpi => 3.0, :ldpi => 4.0}
  @dpi_divider_percentage_hash = {:xxhdpi => "100%", :xhdpi => "67%", :hdpi => "50%", :mdpi => "33%", :ldpi => "25%"}

  class << self
    attr_accessor :dpi_divider_percentage_hash
  end

  def self.calculate(x)
    temp_array = []
    @@dpi_divider_hash.each { |key,value|
      temp_array.push (x.to_i/value).round(1)
    }
    return temp_array
  end
end

####### program starts here ##########
# parse arguments
ARGV.each_with_index do|item, index|
  if item == "-h" || item == "-help"
    @help_flag = true
    @help_arg = ARGV[index+1]
  else
    if item == "-set"
      @set_flag = true
      @set_arg = ARGV[index+1]
    elsif item == "-calculate"
      @calculate_flag = true
      @calculate_arg = ARGV[index+1]
    elsif item == "-resize"
      @resize_flag = true
      @resize_arg = ARGV[index+1]
    end
  end
end
# First check if image path is valid
@image_path = ARGV[0].dup

if @help_flag
  print_help(@help_arg)
elsif @set_flag
  is_image_path_valid = check_if_valid_image_path? @image_path
  if is_image_path_valid
    @image_name = @image_path.split("/").last
    convert_image(get_set_group(@set_arg))
  else
    print "Invalid image path, use -help to get usage instruction"
  end
elsif @calculate_flag
  print "#{Calculator.calculate @calculate_arg}"
elsif @resize_flag
  resize_by_percentage
else
  print_help(@help_arg)
end
#if item == "-h" || item == "-help"

#else
  #print "argv[1]: #{ARGV[1]}"
  #image_path = ARGV[0].dup
  #check_if_valid_image_path? image_path
  #if item == "-set"
      #if ARGV[index+1] == nil
          #puts "invalid usage of -set, type 'ruby hex.rb -help set' for more usage info"
      #end
  #else
      #puts "Invalid argument: #{item}"
  #end
#end
