module Toy
  module Lists
    extend ActiveSupport::Concern

    module ClassMethods
      def lists
        @lists ||= {}
      end

      def list?(key)
        lists.keys.include?(key.to_sym)
      end

      # @examples
      #   list :games                                   # assumes Game
      #   list :games, :dependent => true               # assumes Game
      #   list :active_games, Game                      # uses Game
      #   list :active_games, Game, :dependent => true  # uses Game
      #
      #   list :games do
      #     def active
      #       target.select { |t| t.active? }
      #     end
      #   end
      #
      #   module ActiveExtension
      #     def active
      #       target.select { |t| t.active? }
      #     end
      #   end
      #   list :games, :extensions => [ActiveExtension]
      def list(name, *args, &block)
        List.new(self, name, *args, &block)
      end
    end
  end
end