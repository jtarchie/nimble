# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'integer' do
  include Nimble

  context 'combinator with exact length' do
    it 'returns ok/error' do
      exact_integer = integer(size: 2)

      expect(exact_integer.call('12')).to eq [:ok, [12], '']
      expect(exact_integer.call('123')).to eq [:ok, [12], '3']
      expect(exact_integer.call('1a3')).to eq [:error, [], '1a3']
    end

    it 'returns ok/error with previous document' do
      prefixed_integer = string('T') | integer(size: 2)

      expect(prefixed_integer.call('T12')).to eq [:ok, ['T', 12], '']
      expect(prefixed_integer.call('T123')).to eq [:ok, ['T', 12], '3']
      expect(prefixed_integer.call('T1a3')).to eq [:error, [], 'T1a3']
    end
  end

  context 'with min/max' do
    it 'returns ok/error with min' do
      min_integer = integer(size: 2..)

      expect(min_integer.call('12')).to eq [:ok, [12], '']
      expect(min_integer.call('123')).to eq [:ok, [123], '']
      expect(min_integer.call('123o')).to eq [:ok, [123], 'o']
      expect(min_integer.call('1234')).to eq [:ok, [1234], '']
      expect(min_integer.call('1')).to eq [:error, [], '1']
    end

    it 'returns ok/error with max' do
      max_integer = integer(size: 1..3)

      expect(max_integer.call('1')).to eq [:ok, [1], '']
      expect(max_integer.call('12')).to eq [:ok, [12], '']
      expect(max_integer.call('123')).to eq [:ok, [123], '']
      expect(max_integer.call('1234')).to eq [:ok, [123], '4']
      expect(max_integer.call('123o')).to eq [:ok, [123], 'o']
    end

    it 'returns ok/error with min/max' do
      min_max_integer = integer(size: 2..3)

      expect(min_max_integer.call('1')).to eq [:error, [], '1']
      expect(min_max_integer.call('12')).to eq [:ok, [12], '']
      expect(min_max_integer.call('123')).to eq [:ok, [123], '']
      expect(min_max_integer.call('1234')).to eq [:ok, [123], '4']
      expect(min_max_integer.call('123o')).to eq [:ok, [123], 'o']
    end
  end
end
