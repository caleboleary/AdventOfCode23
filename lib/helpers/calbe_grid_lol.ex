defmodule Helpers.CalbeGridLol do

    #list of lists version

    def parse(input, rowDelimiter, colDelimiter) do
        String.split(input, rowDelimiter, trim: true)
        |> Enum.map(fn row -> 
            String.split(row, colDelimiter, trim: true)
        end)
    end

    def get_grid_len(grid) do
        length(grid)
    end

    def get_grid_width(grid) do
        List.first(grid) |> length()
    end

    def get_by_x_y(grid, x, y, out_of_bounds_response \\ nil) do
        if (
            x >= 0 && 
            y >= 0 &&
            x < (get_grid_width(grid) - 1) &&
            y < (get_grid_len(grid) - 1) 
        ) do
            Enum.at(grid, y) |> Enum.at(x)
        else
            out_of_bounds_response
        end
    end

    def get_by_point_and_transformation(grid, start_x, start_y, {transform_x, transform_y}, out_of_bounds_response \\ nil) do
        get_by_x_y(grid, start_x + transform_x, start_y + transform_y, out_of_bounds_response)
    end

end