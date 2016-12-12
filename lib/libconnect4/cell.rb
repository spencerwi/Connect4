require_relative './constants.rb'
module LibConnect4
    class Cell
        attr_reader :row, :col
        attr_accessor :value
        def initialize(row, col, value: LibConnect4::Empty)
            @row = row
            @col = col
            @value = value
        end
    end
end
