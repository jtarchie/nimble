# frozen_string_literal: true

module Nimble
  def utf8_char(ranges)
    UTF8Char.new(ranges)
  end

  def string(s)
    ::Nimble::String.new(s)
  end

  def integer(size:)
    size = size..size if size.is_a?(::Integer)

    ::Nimble::Integer.new(size)
  end

  def tag(name)
    Tag.new(name)
  end

  def concat(a, b)
    Concat.new([a, b])
  end

  def utf8_string(ranges, size:)
    duplicate(utf8_char(ranges), size) | reduce(:join, [''])
  end

  def reduce(method, args)
    Reduce.new(method, args)
  end

  def replace(machine, value)
    Replace.new(machine, value)
  end

  def empty
    Empty.new
  end

  def duplicate(machine, size)
    return empty if size == 0

    1.upto(size - 1).reduce(machine) do |m, _|
      m | machine
    end
  end

  class Machine
    def |(other)
      Concat.new([self, other])
    end
  end

  class Empty < Machine
    def call(bytes, accum = [])
      [:ok, accum, bytes]
    end
  end

  class Replace < Machine
    def initialize(machine, value)
      @machine = machine
      @value = value
    end

    def call(bytes, accum = [])
      status, accum, bytes = @machine.call(bytes, accum)
      if status == :ok
        [:ok, [@value], bytes]
      else
        [:error, accum, bytes]
      end
    end
  end

  class Reduce < Machine
    def initialize(method, args)
      @method = method
      @args = args
    end

    def call(bytes, accum = [])
      accum = [accum.__send__(@method, *@args)]
      [:ok, accum, bytes]
    end
  end

  class Tag < Machine
    def initialize(name)
      @name = name
    end

    def call(bytes, accum = [])
      [:ok, [@name, accum], bytes]
    end
  end

  class Concat < Machine
    def initialize(machines)
      @machines = machines
    end

    def call(bytes, accum = [])
      original_accum = accum.dup

      leftovers = @machines.reduce(bytes) do |b, machine|
        status, accum, leftovers = machine.call(b, accum)

        case status
        when :ok
          leftovers
        when :error
          return :error, original_accum, bytes
        end
      end

      [:ok, accum, leftovers]
    end
  end

  class Integer < Machine
    def initialize(size)
      @size = size
    end

    def call(bytes, accum = [])
      pos = 0
      number = ''
      regex = if @size.end.nil?
                /^([0-9]{#{@size.min},})/
              elsif @size.begin == @size.end
                /^([0-9]{#{@size.min}})/
              else
                /^([0-9]{#{@size.min},#{@size.max}})/
      end

      matches = regex.match(bytes)
      return :ok, accum.push(matches[1].to_i), bytes[matches[1].length..-1] if matches

      [:error, accum, bytes]
    end
  end

  class String < Machine
    def initialize(string)
      @string = string
    end

    def call(bytes, accum = [])
      length = @string.length
      if bytes[0...length] == @string
        return :ok, accum.push(@string), bytes[length..-1]
      end

      [:error, accum, bytes]
    end
  end

  class UTF8Char < Machine
    def initialize(ranges)
      @ranges = ranges
    end

    def call(bytes, accum = [])
      char = bytes[0]
      accum.push char

      return :ok, accum, bytes[1..-1] if @ranges.empty?

      @ranges.each do |range|
        case range
        when Range
          return :ok, accum, bytes[1..-1] if range.include?(char)
        when Array
          return :ok, accum, bytes[1..-1] if range.empty?
        when Hash
          next if range.fetch(:not).include?(char)
        when ::String
          return :ok, accum, bytes[1..-1] if range == char
        else
          raise "Unsupported range: #{range.inspect}"
        end
      end

      accum.pop
      [:error, accum, bytes]
    end
  end
end
