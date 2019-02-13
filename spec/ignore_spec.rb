# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'ignore combinator' do
  include Nimble

  it "returns ok/error" do
    compile_ignore = string("TO") | ignore()

    expect(compile_ignore.call("TO")).to eq [:ok, [], ""]
    expect(compile_ignore.call("TOC")).to eq [:ok, [], "C"]
    expect(compile_ignore.call("AO")).to eq [:error, [], "AO"]
  end

  it "properly counts newlines" do
    compile_ignore_with_newline = string("T\nO") | ignore()

    expect(compile_ignore_with_newline.call("T\nO")).to eq [:ok, [], ""]
    expect(compile_ignore_with_newline.call("T\nOC")).to eq [:ok, [], "C"]
    expect(compile_ignore_with_newline.call("A\nO")).to eq [:error, [], "A\nO"]
  end
end