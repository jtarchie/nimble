# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'replace combinator' do
  include Nimble

  it 'returns ok/error' do
    compile_replace = replace(string('TO'), 'OTHER')

    expect(compile_replace.call('TO')).to eq [:ok, ['OTHER'], '']
    expect(compile_replace.call('TOC')).to eq [:ok, ['OTHER'], 'C']
    expect(compile_replace.call('AO')).to eq [:error, [], 'AO']
  end

  it 'can replace empty' do
    compile_replace_empty = replace(empty, 'OTHER')

    expect(compile_replace_empty.call('TO')).to eq [:ok, ['OTHER'], 'TO']
  end

  it 'properly counts newlines' do
    compile_replace_with_newline = replace(string("T\nO"), 'OTHER')

    expect(compile_replace_with_newline.call("T\nO")).to eq [:ok, ['OTHER'], '']
    expect(compile_replace_with_newline.call("T\nOC")).to eq [:ok, ['OTHER'], 'C']
    expect(compile_replace_with_newline.call("A\nO")).to eq [:error, [], "A\nO"]
  end
end
