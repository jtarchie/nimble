# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'map combinator' do
  include Nimble

  it 'returns ok/error' do
    remote_map = utf8_char(['a'..'z']) + utf8_char(['a'..'z']) + utf8_char(['a'..'z']) + map { |v| v.to_i(26) }

    expect(remote_map.call('abc')).to eq [:ok, [10, 11, 12], '']
    expect(remote_map.call('abcd')).to eq [:ok, [10, 11, 12], 'd']
    expect(remote_map.call('1abcd')).to eq [:error, [], '1abcd']
  end

  it 'can map empty' do
    empty_map = empty + map(&:to_i)

    expect(empty_map.call('abc')).to eq [:ok, [], 'abc']
  end
end
