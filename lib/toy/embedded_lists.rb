module Toy
  module EmbeddedLists
    extend ActiveSupport::Concern

    module ClassMethods
      def embedded_lists
        @lists ||= {}
      end

      # @examples
      #   list :moves                                   # assumes Move
      #   list :moves, :dependent => true               # assumes Move
      #   list :recent_moves, Move                      # uses Move
      #   list :recent_moves, Move, :dependent => true  # uses Move
      #
      #   embedded_list :moves do
      #     def recent
      #       target.select { |t| t.recent? }
      #     end
      #   end
      #
      #   module RecentExtension
      #     def recent
      #       target.select { |t| t.recent? }
      #     end
      #   end
      #   embedded_list :moves, :extensions => [RecentExtension]
      def embedded_list(name, *args, &block)
        EmbeddedList.new(self, name, *args, &block)
      end
    end
  end
end