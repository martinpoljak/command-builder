# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "hash-utils/object"
require "hash-utils/array"
require "pipe-run"

##
# Represents one command line command with arguments and parameters.
#

class CommandBuilder

    ##
    # Holds command name.
    # @return [String, Symbol] command body
    #

    attr_accessor :command
    @command
    
    ##
    # Holds separators matrix. It's four-items array:
    # - short argument separator,
    # - short argument name/value separator,
    # - long argument separator,
    # - short argument name/value separator.
    #
    # Here is some example in the same order as in command:
    #
    #   # ["-", " ", "--", "="]
    #   command -s something --long=something
    #
    # @return [Array] separators matrix
    #
    
    attr_accessor :separators
    @separators
    
    ##
    # Holds arguments array. Each item is array pair with argument 
    # name and value.
    #
    # @return [Array] array of argument pairs
    #

    attr_accessor :args
    @args
    
    ##
    # Holds parameters array.
    #
    
    @params
    
    ##
    # Constructor.
    #
    # @param [String, Symbol] command target command
    # @param [Array] separators separators matrix
    # @see #separators
    #
    
    def initialize(command, separators = ["-", " ", "--", "="])
        @command = command
        @separators = separators
        self.reset!
    end
    
    ##
    # Adds argument to command.
    #
    # One-letter arguments will be treated as "short" arguments for the 
    # syntax purposes, other as "long". See {#separators}.
    #
    # @example with default set of {#separators}
    #   cmd = Command::new(:jpegoptim)
    #   @cmd.argument(:p)           # will be rendered as 'jpegoptim -p'
    #   @cmd.argument(:preserve)    # will be rendered as 'jpegoptim -p --preserve'
    #   @cmd.argument(:m, 2)        # will be rendered as 'jpegoptim -p --preserve -m 2'
    #   @cmd.argument(:max, 2)      # will be rendered as 'jpegoptim -p --preserve -m 2 --max=2'
    # @example with array-like call
    #   cmd = Command::new(:jpegoptim)
    #   @cmd[:m] = 2                # will be rendered as 'jpegoptim -m 2'
    #   @cmd[:max] = 2              # will be rendered as 'jpegoptim -m 2 --max=2'
    #
    #   # But be warn, it pushes to arguments array as you can se, so 
    #   # already existing values will not be replaced!
    #
    # @param [String, Symbol] name of the argument
    # @param [Object] value of the argument
    #
    
    def argument(name, value = nil)
        @args << [name, value]
    end
    
    alias :arg :argument
    alias :[]= :argument
    
    ##
    # Returns array of argument pairs with given name.
    #
    # @param [String, Symbol] name argument name
    # @return [Array] array of array pairs with this name
    #
    
    def [](name)
        @args.select { |k, v| name == k } 
    end
    
    ##
    # Adds parameter to command.
    # @param [Object] value value of the prameter convertable to String.
    # 
    
    def parameter(value)
        @params << value
    end
    
    alias :param :parameter
    
    ##
    # Adds multiple parameters to command at once. If no values are 
    # given, returns the current parameters array.
    #
    # @overload parameters
    #   Returns current parameters array.
    #   @return [Array] current parameters array
    # @overload parameters(values)
    #   Adds multiple parameters at once.
    #   @param [Array] values array of values
    #   @see #parameter
    #
    
    def parameters(values = nil)
        if values.nil?
            return @params
        else
            @params += values
        end
    end
    
    alias :params :parameters

    ##
    # Adds an item to command. If option is Symbol or value isn't +nil+,
    # it will apply the item as an argument, in otherwise, it will treat
    # as an symbol.
    #
    # @overload add(option)
    #   Adds parameter.
    #   @param [Object] option parameter value
    #   @see #parameter
    # @overload add(options)
    #   Adds parameters
    #   @param [Array] options parameters values
    #   @see #parameters
    # @overload add(option, value = nil)
    #   Adds argument.
    #   @param [Symbol] option argument name
    #   @param [Object] value argument value
    #   @see #argument
    #
    # @example
    #   cmd = Command::new(:jpegoptim)
    #   cmd << :preserve    # will be rendered as 'jpegoptim --preserve'
    #   cmd << "file.jpg"   # will be rendered as 'jpegoptiom --preserve file.jpg'
    #
    
    def add(option, value = nil)
        if option.symbol? or not value.nil?
            self.argument(option, value)
        elsif option.array?
            self.parameters(option)
        else
            self.parameter(option)
        end
    end
    
    alias :<< :add
    
    ##
    # Quotes value for use in command line.
    #
    # Uses some heuristic for setting the right quotation. If both 
    # " and ' are found, escapes ' by \ and quotes by ". If only one of
    # them found, escapes by the second one. If space found in the 
    # string, quotes by " too.
    #
    # @example
    #   cmd = Command::new(:jpegoptim)
    #   cmd.escape("hello 'something' world")   # will result to < "hello 'something' world" >
    #   cmd.escape('hello "something" world')   # will result to < 'hello "something" world' >
    #   cmd.escape('hello "som\'thing" world')  # will result to < "hello \"som'thing\" world" >
    #   cmd.escape('hello something world')     # will result to < "hello something world" >
    #
    # @param [String] value string for escaping
    # @return [String] quoted value
    #
    
    def quote(value)
        value = value.to_s

        # Looks for " and '
        single = value["'"].to_b
        double = value['"'].to_b
        
        # According to found characters selects quotation
        if single and value
            value = value.gsub('"', '\\"')
            quotation = '"'
        elsif single
            quotation = '"'
        elsif double
            quotation = "'"
        elsif value[" "]
            quotation = '"'
        else
            quotation = ""
        end

        # Returns
        return quotation + value + quotation
    end
    
    ##
    # Executes the command. If block given, takes it output of the 
    # command and runs it asynchronously using EventMachine.
    #
    # @see https://github.com/martinkozak/pipe-run
    # @param [Proc] block if asynchronous run
    # @return [String] output of the command or nil if asynchronous
    #
    
    def execute(&block)
        callback = nil
        if not block.nil?
            callback = Proc::new do |out|
                block.call(out, out.strip.empty?)
            end
        end
        
        Pipe::run(self.to_s, &callback)
    end
    
    alias :exec :execute
    alias :"exec!" :execute
    alias :"execute!" :execute
    
    ##
    # Converts command to string.
    # @return [String] command in string form
    #

    def to_s
        cmd = @command.to_s.gsub(" ", "\\ ")
        
        # Arguments
        @args.each do |name, value|
            __add_arg(cmd, name, value)
        end
        
        # Parameters
        @params.each do |param|
            cmd << " " << self.quote(param.to_s)
        end
        
        return cmd
    end
    
    ##
    # Resets the arguments and parameters so prepares it for new build.
    #
    # @return [CommandBuilder] self instance
    # @since 0.1.1
    #
    
    def reset!
        @args = [ ]
        @params = [ ]
        self
    end
    
    alias :reset :"reset!"
    
    
    private
    
    ##
    # Adds argument to command.
    #
    
    def __add_arg(cmd, name, value)
        cmd << " "
        name = name.to_s
        
        # Name
        short = (name.length == 1)
        
        if short
            cmd << @separators.first
        else
            cmd << @separators.third
        end
        cmd << name
        
        # Value
        if not value.nil?
            if short
                cmd << @separators.second
            else
                cmd << @separators.fourth
            end
            cmd << self.quote(value.to_s)
        end
    end
    
end
