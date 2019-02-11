# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'reduce combinator' do
  include Nimble

  it 'returns ok/error' do
    remote_reduce = utf8_char(['a'..'z']) | utf8_char(['a'..'z']) | utf8_char(['a'..'z']) | reduce(:join, ['-'])

    expect(remote_reduce.call('abc')).to eq [:ok, ['a-b-c'], '']
    expect(remote_reduce.call('abcd')).to eq [:ok, ['a-b-c'], 'd']
    expect(remote_reduce.call('1abcd')).to eq [:error, [], '1abcd']
  end
end
