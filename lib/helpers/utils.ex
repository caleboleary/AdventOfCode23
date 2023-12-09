defmodule Helpers.Utils do
    
    def inspect(thing) do
        IO.inspect(thing, [charlists: :as_lists])
    end

    def dump_to_file(data, filename) do
        to_write = data
        |> Enum.join("\n")
    
        File.write!("dumps/#{filename}.txt", to_write)
    
        data
    end

    def log_interval(data_to_log, log_when_divisible_by, step) do
        if rem(step, log_when_divisible_by) == 0 do
            inspect(data_to_log)
        end

        data_to_log
    end

end