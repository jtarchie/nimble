# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'repeat combinator' do
  include Nimble

  let(:ascii_to_string) { utf8_char(['0'..'9']) + map(&:to_s) }

  it 'returns ok/error' do
    repeat_digits = repeat(utf8_char(['0'..'9']) + utf8_char(['0'..'9']))

    expect(repeat_digits.call('12')).to eq [:ok, %w[1 2], '']
    expect(repeat_digits.call('123')).to eq [:ok, %w[1 2], '3']
    expect(repeat_digits.call('a123')).to eq [:ok, [], 'a123']
  end

  it 'returns ok/error with map' do
    repeat_digits_to_string = repeat(ascii_to_string)

    expect(repeat_digits_to_string.call('123')).to eq [:ok, %w[1 2 3], '']
  end

  it 'returns ok/error with inner and outer map' do
    repeat_digits_to_same_inner = repeat(ascii_to_string + map(&:to_s))
    repeat_digits_to_same_outer = repeat(ascii_to_string) + map(&:to_s)

    expect(repeat_digits_to_same_inner.call('123')).to eq [:ok, %w[1 2 3], '']
    expect(repeat_digits_to_same_outer.call('123')).to eq [:ok, %w[1 2 3], '']
  end

  it 'returns ok/error with concat map' do
    repeat_double_digits_to_string =
      repeat(
        concat(
          utf8_char(['0'..'9']) + map(&:to_s),
          utf8_char(['0'..'9']) + map(&:to_s)
        )
      )

    expect(repeat_double_digits_to_string.call('12')).to eq [:ok, %w[1 2], '']
    expect(repeat_double_digits_to_string.call('123')).to eq [:ok, %w[1 2], '3']
    expect(repeat_double_digits_to_string.call('a123')).to eq [:ok, [], 'a123']
  end
end
