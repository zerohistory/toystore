module Toy
  module Lists
    extend ActiveSupport::Concern

    module ClassMethods
      def lists
        @lists ||= {}
      end

      # @examples
      #   list :games                                   # assumes Game
      #   list :games, :dependent => true               # assumes Game
      #   list :active_games, Game                      # uses Game
      #   list :active_games, Game, :dependent => true  # uses Game
      def list(name, *args)
        List.new(self, name, *args)
      end
    end
  end
end