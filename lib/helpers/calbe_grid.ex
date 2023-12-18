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

        IO.puts("---grid---")
        Enum.reduce(0..(get_grid_len(grid) - 1), "", fn y, acc -> 
            Enum.reduce(0..(get_grid_width(grid) - 1), acc, fn x, acc -> 
                acc <> get_by_x_y(grid, x, y) <> ""
            end) <> "\n"
        end)
        |> IO.write()
        IO.puts("---grid---")


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

    def get_row(grid, y) do
        Enum.reduce(0..(get_grid_width(grid) - 1), [], fn x, acc -> 
            acc ++ [get_by_x_y(grid, x, y)]
        end)
    end

    def get_col(grid, x) do
        Enum.reduce(0..(get_grid_len(grid) - 1), [], fn y, acc -> 
            acc ++ [get_by_x_y(grid, x, y)]
        end)
    end

    # based on my impl from last year https://github.com/caleboleary/AdventOfCode22/blob/main/day12/day12pt1.exs
    def dijkstra(grid, {start_x, start_y}, get_viable_moves, get_should_halt, get_weight) do

        priority_queue = Enum.filter(grid, fn {point, cell} -> 
            point != :util
        end)
        |> Enum.map(fn {point, cell} -> 
            {point, if point == {start_x, start_y} do 0 else :infinity end}
        end)
        |> Enum.sort(fn {_, a}, {_, b} -> a < b end)

        Enum.reduce_while(1..20000, %{priority_queue: priority_queue, visited_nodes: [], predecessors: %{}}, fn _iteration, acc ->

            {current_node, current_node_dist} = Enum.find(acc.priority_queue, fn {key, _} -> !Enum.member?(acc.visited_nodes, key) end)

            viable_neighbors = get_viable_moves.(grid, current_node, acc.predecessors)
            |> Enum.map(fn neighbor -> 
                neighbor[:coords]
            end)

            new_priority_queue_and_preds = Enum.reduce(viable_neighbors, {acc.priority_queue, acc.predecessors}, fn neighbor, {acc2, preds} ->
                
                neighbor_dist = Enum.find(acc.priority_queue, fn {key, _} -> key == neighbor end) |> elem(1)  

                if neighbor_dist === :infinity or neighbor_dist > current_node_dist + 1 do

                    base_dist = if current_node_dist === :infinity do 0 else current_node_dist end

                    filtered_acc2 = acc2 |> Enum.filter(fn {key, _} -> key != neighbor end)

                    new_entry = {neighbor, base_dist + get_weight.(grid, neighbor)}

                    new_preds = Map.put(preds, neighbor, current_node)

                    {filtered_acc2 ++ [new_entry], new_preds}
                else
                    {acc2, preds}
                end
            end)

            new_priority_queue = new_priority_queue_and_preds |> elem(0)
            |> Enum.sort(fn {_, a}, {_, b} -> a < b end)

            new_predecessors = new_priority_queue_and_preds |> elem(1)

            new_visited_nodes = [current_node | acc.visited_nodes]

            should_halt = get_should_halt.(grid, new_priority_queue)

            if should_halt do
                {:halt, {new_priority_queue, new_predecessors}}
            else
                {:cont, %{priority_queue: new_priority_queue, visited_nodes: new_visited_nodes, predecessors: new_predecessors}}
            end

        end)

    end

    #example
    # def get_possible_moves(grid, {curr_x, curr_y}) do 

    #     alphabet = "abcdefghijklmnopqrstuvwxyz"
    
    #     {start_x, start_y} = Helpers.CalbeGrid.find_point(grid, fn cell -> cell == "S" end)
    #     {end_x, end_y} = Helpers.CalbeGrid.find_point(grid, fn cell -> cell == "E" end)
    
    #     #overwrite start with a and end with z
    #     grid = Helpers.CalbeGrid.set_by_x_y(grid, start_x, start_y, "a")
    #     |> Helpers.CalbeGrid.set_by_x_y(end_x, end_y, "z")
    
    #     possible_moves = [
    #       {curr_x + 1, curr_y},
    #       {curr_x - 1, curr_y},
    #       {curr_x, curr_y + 1},
    #       {curr_x, curr_y - 1}
    #     ]
    #     |> Enum.map(fn {x, y} -> 
    #       %{coords: {x, y}, cell: Helpers.CalbeGrid.get_by_x_y(grid, x, y)}
    #     end)
    #     |> IO.inspect([label: "possible_moves", charlists: :as_lists])
    #     |> Enum.filter(fn move -> move[:cell] != nil end)
    #     |> IO.inspect([label: "possible_moves_filt", charlists: :as_lists])
    #     |> Enum.filter(fn move -> 
    #       IO.inspect(Helpers.CalbeGrid.get_by_x_y(grid, curr_x, curr_y), [label: "curr cell"])
    #       IO.inspect(move[:cell], [label: "considering a move to this cell"])
    #       str_index_of(alphabet, move[:cell]) <= (str_index_of(alphabet, Helpers.CalbeGrid.get_by_x_y(grid, curr_x, curr_y)) + 1)
    #     end)
    #     |> IO.inspect([label: "possible_moves_filt2", charlists: :as_lists])

    #   end
    
    #   def get_should_halt(grid, priority_queue) do
    
    #     end_point = Helpers.CalbeGrid.find_point(grid, fn cell -> cell == "E" end)
    #     |> IO.inspect([label: "end_point", charlists: :as_lists])
    
    #     end_dist = Enum.find(priority_queue, fn {point, _} -> point == end_point end) |> elem(1)
    #     |> IO.inspect([label: "end_dist", charlists: :as_lists])
    
    #     end_dist != :infinity
        
    #   end



    # start = Helpers.CalbeGrid.find_point(grid, fn cell -> cell == "S" end)

    # Helpers.CalbeGrid.dijkstra(grid, start, &get_possible_moves/2, &get_should_halt/2)

    #returns priority queue
    

end