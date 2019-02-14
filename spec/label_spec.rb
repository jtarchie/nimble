# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'choice combinator' do
  include Nimble

  it 'returns ok/error' do
    compile_label = label(string('TO'), 'label')

    expect(compile_label.call('TO')).to eq [:ok, ['TO'], '']
    expect(compile_label.call('TOC')).to eq [:ok, ['TO'], 'C']
    expect(compile_label.call('AO')).to eq [:error, 'expected label', 'AO']
  end

  it 'properly counts newlines' do
    compile_label_with_newline = label(string("T\nO"), 'label')

    expect(compile_label_with_newline.call("T\nO")).to eq [:ok, ["T\nO"], '']
    expect(compile_label_with_newline.call("T\nOC")).to eq [:ok, ["T\nO"], 'C']
    expect(compile_label_with_newline.call("A\nO")).to eq [:error, 'expected label', "A\nO"]
  end
end
