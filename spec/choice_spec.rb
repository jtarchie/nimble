# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'choice combinator' do
  include Nimble

  it 'returns ok/error' do
    simple_choice = choice([utf8_char(['a'..'z']), utf8_char(['A'..'Z']), utf8_char(['0'..'9'])])

    expect(simple_choice.call('a=')).to eq [:ok, ['a'], '=']
    expect(simple_choice.call('A=')).to eq [:ok, ['A'], '=']
    expect(simple_choice.call('0=')).to eq [:ok, ['0'], '=']
    expect(simple_choice.call('+=')).to eq [:error, [], '+=']
  end

  it 'returns ok/error with wrapping label' do
    choice_label = label(
      choice([utf8_char(['a'..'z']), utf8_char(['A'..'Z']), utf8_char(['0'..'9'])]),
      'something'
    )

    expect(choice_label.call('a=')).to eq [:ok, ['a'], '=']
    expect(choice_label.call('A=')).to eq [:ok, ['A'], '=']
    expect(choice_label.call('0=')).to eq [:ok, ['0'], '=']
    expect(choice_label.call('+=')).to eq [:error, 'expected something', '+=']
  end

  it 'returns ok/error with repeat inside' do
    choice_inner_repeat = choice([repeat(utf8_char(['a'..'z'])), repeat(utf8_char(['A'..'Z']))])

    expect(choice_inner_repeat.call('az')).to eq [:ok, %w[a z], '']
    expect(choice_inner_repeat.call('AZ')).to eq [:ok, [], 'AZ']
  end

  it 'returns ok/error with repeat outside' do
    choice_outer_repeat = repeat(choice([utf8_char(['a'..'z']), utf8_char(['A'..'Z'])]))

    expect(choice_outer_repeat.call('az')).to eq [:ok, %w[a z], '']
    expect(choice_outer_repeat.call('AZ')).to eq [:ok, %w[A Z], '']
    expect(choice_outer_repeat.call('aAzZ')).to eq [:ok, %w[a A z Z], '']
  end

  it 'returns ok/error with repeat and inner map' do
    choice_repeat_and_inner_map =
      repeat(
        choice([
                 utf8_char(['a'..'z']) + map(&:to_s),
                 utf8_char(['A'..'Z']) + map(&:to_s)
               ])
      )

    expect(choice_repeat_and_inner_map.call('az')).to eq [:ok, %w[a z], '']
    expect(choice_repeat_and_inner_map.call('AZ')).to eq [:ok, %w[A Z], '']
    expect(choice_repeat_and_inner_map.call('aAzZ')).to eq [:ok, %w[a A z Z], '']
  end

  it 'returns ok/error with repeat and maps' do
    choice_repeat_and_maps = repeat(
      choice([
               utf8_char(['a'..'z']) + map(&:ord),
               utf8_char(['A'..'Z']) + map(&:ord)
             ])
    ) + map(&:chr)

    expect(choice_repeat_and_maps.call('az')).to eq [:ok, %w[a z], '']
    expect(choice_repeat_and_maps.call('AZ')).to eq [:ok, %w[A Z], '']
    expect(choice_repeat_and_maps.call('aAzZ')).to eq [:ok, %w[a A z Z], '']
  end

  it 'returns ok/error on empty' do
    choice_with_empty =
      choice([
               utf8_char(['a'..'z']),
               empty
             ])
    expect(choice_with_empty.call('az')).to eq [:ok, ['a'], 'z']
    expect(choice_with_empty.call('AZ')).to eq [:ok, [], 'AZ']
  end
end
