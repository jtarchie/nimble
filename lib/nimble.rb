# frozen_string_literal: true

module Nimble
  def ascii_char(ranges)
    AsciiChar.new(ranges)
  end

  def string(s)
    ::Nimble::String.new(s)
  end

  def integer(size)
    ::Nimble::Integer.new(size)
  end

  class Machine
    def |(other)
      Concat.new([self, other])
    end
  end

  class Concat < Machine
    def initialize(machines)
      @machines = machines
    end

    def call(bytes, accum = [])
      leftovers = @machines.reduce(bytes) do |b, machine|
        status, accum, leftovers = machine.call(b, accum)

        case status
        when :ok
          leftovers
        when :error
          return :error, accum, leftovers
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
      return :error, accum, bytes unless bytes.length >= @size

      integer = bytes[0...@size].to_i
      return :ok, accum.push(integer), bytes[@size..-1] if integer.to_s == bytes[0...@size]

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

  class AsciiChar < Machine
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
