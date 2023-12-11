defmodule Helpers.CalbeGrid do

    def parse(input, rowDelimiter, colDelimiter) do
        list_grid = String.split(input, rowDelimiter, trim: true)
        |> Enum.map(fn row -> 
            String.split(row, colDelimiter, trim: true)
        end)

        map_grid = Enum.reduce(list_grid, %{}, fn (row, acc) ->
            Enum.with_index(list_grid)
            |> Enum.reduce(%{}, fn ({row, y}, acc) ->
                Enum.with_index(row) |> Enum.reduce(acc, fn ({cell, x}, acc) ->
                    Map.put(acc, {x, y}, cell)
                end)
            end)
        end)

        Map.put(map_grid, :util, %{
            len: length(list_grid),
            width: List.first(list_grid) |> length()
        })
        
    end

    def get_grid_len(grid) do
        grid[:util][:len]
    end

    def get_grid_width(grid) do
        grid[:util][:width]
    end

    def get_by_x_y(grid, x, y, out_of_bounds_response \\ nil) do
        if (
            x >= 0 && 
            y >= 0 &&
            x <= (get_grid_width(grid) - 1) &&
            y <= (get_grid_len(grid) - 1) 
        ) do
            grid[{x, y}]
        else
            out_of_bounds_response
        end
    end

    def set_by_x_y(grid, x, y, value) do
        Map.put(grid, {x, y}, value)
    end

    def extract_text_representation(grid, rowDelimiter \\ "\n", colDelimiter \\ "") do
        Enum.reduce(0..(get_grid_len(grid) - 1), "", fn y, acc -> 
            Enum.reduce(0..(get_grid_width(grid) - 1), acc, fn x, acc -> 
                acc <> get_by_x_y(grid, x, y) <> colDelimiter
            end) <> rowDelimiter
        end)
    end

    def visualize_grid(grid) do
        Enum.reduce(0..(get_grid_len(grid) - 1), "", fn y, acc -> 
            Enum.reduce(0..(get_grid_width(grid) - 1), acc, fn x, acc -> 
                acc <> get_by_x_y(grid, x, y) <> ""
            end) <> "\n"
        end)
        |> IO.write()

        grid
    end

    def get_by_point_and_transformation(grid, start_x, start_y, {transform_x, transform_y}, out_of_bounds_response \\ nil) do
        get_by_x_y(grid, start_x + transform_x, start_y + transform_y, out_of_bounds_response)
    end

    def find_point(grid, find_func) do
        Enum.find_value(grid, fn {point, cell} -> 
            if find_func.(cell) do
                point
            else
                nil
            end
        end)
    end

    def filter_points(grid, filter_func) do
        Enum.filter(grid, fn {point, cell} -> 
            filter_func.(cell)
        end)
    end

end