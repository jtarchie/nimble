# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'utf8_char combinator without newlines' do
  include Nimble

  it 'returns ok/error on composition' do
    only_ascii = utf8_char(['0'..'9']) | utf8_char([])

    expect(only_ascii.call('1a')).to eq [:ok, %w[1 a], '']
    expect(only_ascii.call('11')).to eq [:ok, %w[1 1], '']
    expect(only_ascii.call('a1')).to eq [:error, [], 'a1']
  end

  it 'returns on ok/error on multiple ranges' do
    multi_ascii = utf8_char(['0'..'9', 'z'..'a'])

    expect(multi_ascii.call('1a')).to eq [:ok, ['1'], 'a']
    expect(multi_ascii.call('a1')).to eq [:ok, ['a'], '1']
    expect(multi_ascii.call('++')).to eq [:error, [], '++']
  end

  it 'return ok/error on multiple ranges with not' do
    multi_ascii_with_not = utf8_char(['0'..'9', 'z'..'a', { not: 'c' }])

    expect(multi_ascii_with_not.call('1a')).to  eq [:ok, ['1'], 'a']
    expect(multi_ascii_with_not.call('a1')).to  eq [:ok, ['a'], '1']
    expect(multi_ascii_with_not.call('++')).to  eq [:error, [], '++']
    expect(multi_ascii_with_not.call('cc')).to  eq [:error, [], 'cc']
  end

  it 'returns ok/error on multiple ranges with multiple not' do
    multi_ascii_with_multi_not = utf8_char(['0'..'9', 'z'..'a', { not: 'c' }, { not: 'd'..'e' }])

    expect(multi_ascii_with_multi_not.call('1a')).to eq [:ok, ['1'], 'a']
    expect(multi_ascii_with_multi_not.call('a1')).to eq [:ok, ['a'], '1']
    expect(multi_ascii_with_multi_not.call('++')).to eq [:error, [], '++']
    expect(multi_ascii_with_multi_not.call('cc')).to eq [:error, [], 'cc']
    expect(multi_ascii_with_multi_not.call('de')).to eq [:error, [], 'de']
  end

  it 'returns ok/error even with newlines' do
    ascii_newline = utf8_char(['0'..'9', "\n"]) | utf8_char(['a'..'z', "\n"])

    expect(ascii_newline.call("1a\n")).to eq [:ok, %w[1 a], "\n"]
    expect(ascii_newline.call("1\na")).to eq [:ok, %W[1 \n], 'a']
    expect(ascii_newline.call("\nao")).to eq [:ok, %W[\n a], 'o']
  end

  context 'when using utf8 utf8_characters' do
    it 'returns ok/error on composition' do
      only_utf8 = utf8_char(['0'..'9']) | utf8_char([])

      expect(only_utf8.call('1a')).to eq [:ok, %w[1 a], '']
      expect(only_utf8.call('11')).to eq [:ok, %w[1 1], '']
      expect(only_utf8.call('1é')).to eq [:ok, %w[1 é], '']
      expect(only_utf8.call('a1')).to eq [:error, [], 'a1']
    end

    it 'returns ok/error even with newlines' do
      utf8_newline = utf8_char([]) | utf8_char(['a'..'z', "\n"])

      expect(utf8_newline.call("1a\n")).to eq [:ok, %w[1 a], "\n"]
      expect(utf8_newline.call("1\na")).to eq [:ok, %W[1 \n], 'a']
      expect(utf8_newline.call("éa\n")).to eq [:ok, %w[é a], "\n"]
      expect(utf8_newline.call("é\na")).to eq [:ok, %W[é \n], 'a']
      expect(utf8_newline.call("\nao")).to eq [:ok, %W[\n a], 'o']
    end
  end
end
