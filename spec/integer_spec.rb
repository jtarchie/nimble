# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'integer combinator with exact length' do
  include Nimble

  it 'returns ok/error' do
    exact_integer = integer(2)

    expect(exact_integer.call('12')).to eq [:ok, [12], '']
    expect(exact_integer.call('123')).to eq [:ok, [12], '3']
    expect(exact_integer.call('1a3')).to eq [:error, [], '1a3']
  end

  it 'returns ok/error with previous document' do
    prefixed_integer = string('T') | integer(2)

    expect(prefixed_integer.call('T12')).to eq [:ok, ['T', 12], '']
    expect(prefixed_integer.call('T123')).to eq [:ok, ['T', 12], '3']
    expect(prefixed_integer.call('T1a3')).to eq [:error, [], 'T1a3']
  end
end
