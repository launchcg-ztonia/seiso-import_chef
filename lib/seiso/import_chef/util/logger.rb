# TODO Maybe consolidate with the logger in seiso-import_master. [WLW]
class Seiso::ImportChef

  # TODO Allow clients to enable/disable color codes. [WLW]
  class Util::Logger

    def initialize(name)
      @name = name
    end

    def info(message)
      puts "[INFO] #{@name} : #{message}"
    end

    def success(message)
      puts "[SUCCESS] #{@name} : #{message}".green
    end

    def warn(message)
      puts "[WARN] #{@name} : #{message}".yellow
    end

    def error(message)
      STDERR.puts "[ERROR] #{@name} : #{message}".red
    end
  end
end

# http://stackoverflow.com/questions/1489183/colorized-ruby-output
# FIXME Move to more appropriate location. Not sure where something like this should go. [WLW]
class String

  def colorize(color_code)
      "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end
