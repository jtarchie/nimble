# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'ascii_string combinator with exact length' do
  include Nimble

  it 'returns ok/error' do
    exact_ascii_string = utf8_string(['a'..'z'], size: 2)

    expect(exact_ascii_string.call('ab')).to eq [:ok, ['ab'], '']
    expect(exact_ascii_string.call('abc')).to eq [:ok, ['ab'], 'c']
    expect(exact_ascii_string.call('1ab')).to eq [:error, [], '1ab']
  end
end
