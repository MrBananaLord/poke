# frozen_string_literal: true

require 'pastel'

require 'tty-cursor'

module Poke
  class Paint
    def self.welcome
      [
        Pastel.new.decorate(' POKE > ', :black, :on_yellow),
        "\n\n"
      ].join
    end

    def self.farewell
      [
        "\n",
        Pastel.new.decorate(' < kthxbye ', :black, :on_yellow),
        "\n"
      ].join
    end
  end
end
