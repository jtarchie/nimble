# frozen_string_literal: true

require 'spec_helper'
require 'pp'
require_relative '../lib/nimble'

RSpec.describe 'duplicate combinator' do
  include Nimble

  it 'returns ok/error when bound' do
    duplicate_twice = utf8_char(['0'..'9']) + duplicate(utf8_char(['a'..'z']), 2)
    duplicate_zero = utf8_char(['0'..'9']) + duplicate(utf8_char(['a'..'z']), 0)

    expect(duplicate_twice.call('0ab')).to eq [:ok, %w[0 a b], '']
    expect(duplicate_zero.call('0ab')).to eq [:ok, ['0'], 'ab']
  end
end
