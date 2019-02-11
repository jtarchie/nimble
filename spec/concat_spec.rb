# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/nimble'

RSpec.describe 'concat combinator' do
  include Nimble

  it 'returns ok/error' do
    concat_digit_upper_lower_plus =
      concat(
        concat(utf8_char(['0'..'9']), utf8_char(['A'..'Z'])),
        concat(utf8_char(['a'..'z']), utf8_char(['+'..'+']))
      )

    expect(concat_digit_upper_lower_plus.call('1Az+')).to eq [:ok, ['1', 'A', 'z', '+'], '']
  end
end
