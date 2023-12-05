defmodule Helpers.Utils do
    
    def inspect(thing) do
        IO.inspect(thing, [charlists: :as_lists])
    end

end