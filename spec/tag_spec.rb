# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'tag combinator' do
  include Nimble

  it 'returns ok/error' do
    two_integers_tagged = integer(size: 1) | integer(size: 1) | tag(:ints)

    expect(two_integers_tagged.call('12')).to eq [:ok, [:ints, [1, 2]], '']
    expect(two_integers_tagged.call('123')).to eq [:ok, [:ints, [1, 2]], '3']
    expect(two_integers_tagged.call('a12')).to eq [:error, [], 'a12']
  end
end
