# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'string combinator' do
  include Nimble

  it 'returns ok/error' do
    only_string = string('TO')

    expect(only_string.call('TO')).to eq [:ok, ['TO'], '']
    expect(only_string.call('TOC')).to eq [:ok, ['TO'], 'C']
    expect(only_string.call('AO')).to eq [:error, [], 'AO']
  end
end
