# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'ascii_char combinator without newlines' do
  include Nimble

  it 'returns ok/error on composition' do
    only_ascii = ascii_char(['0'..'9']) | ascii_char([])

    expect(only_ascii.call('1a')).to eq [:ok, %w[1 a], '']
    expect(only_ascii.call('11')).to eq [:ok, %w[1 1], '']
    expect(only_ascii.call('a1')).to eq [:error, [], 'a1']
  end
end
