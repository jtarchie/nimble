# frozen_string_literal: true

module Nimble
  def ascii_char(ranges)
    Machine.new(lambda { |bytes, accum|
      char = bytes[0]
      accum.push char

      return :ok, accum, bytes[1..-1] if ranges.empty?

      ranges.each do |range|
        case range
        when Range
          return :ok, accum, bytes[1..-1] if range.include?(char)
        when Array
          return :ok, accum, bytes[1..-1] if range.empty?
        else
          raise "Unsupported range: #{range.inspect}"
        end
      end

      accum.pop
      return :error, accum, bytes
    })
  end

  class Machine
    def initialize(block)
      @block = block
    end

    def call(bytes, accum = [])
      @block.call(bytes, accum)
    end

    def |(other)
      machines = [self, other]
      Machine.new(lambda { |bytes, accum|
        leftovers = machines.reduce(bytes) do |b, machine|
          status, accum, leftovers = machine.call(b, accum)

          case status
          when :ok
            leftovers
          when :error
            return :error, accum, leftovers
          end
        end

        return :ok, accum, leftovers
      })
    end
  end
end
