defmodule AdventOfCode.Day17 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(17, 2023)

#     input = "2413432311323
# 3215453535623
# 3255245654254
# 3446585845452
# 4546657867536
# 1438598798454
# 4457876987766
# 3637877979653
# 4654967986887
# 4564679986453
# 1224686865563
# 2546548887735
# 4322674655533"

    Helpers.CalbeGrid.parse(input, "\n", "")

  end

  defp get_viable_moves(grid, node, _predecessors) do

    {pos, most_recent_direction} = node
   
    {x, y} = pos

    new_direction = if most_recent_direction == :horiz do :vert else :horiz end
    
    Enum.flat_map([-1, 1], fn direction -> 
      Enum.flat_map(1..3, fn distance -> 
        if (most_recent_direction == :horiz) do
          [
            {{x, y + (direction * distance)}, new_direction},
            {{x, y - (direction * distance)}, new_direction},
          ]
        else
          [
            {{x + (direction * distance), y}, new_direction},
            {{x - (direction * distance), y}, new_direction},
          ]
        end
      end)
    end)
    |> Enum.filter(fn {move, dir} ->
      {move_x, move_y} = move
      
      Helpers.CalbeGrid.get_by_x_y(grid, move_x, move_y, nil) != nil
    end)
       
  end

  defp get_should_halt(grid, priority_queue) do
    
    grid_len = Helpers.CalbeGrid.get_grid_len(grid)
    grid_width = Helpers.CalbeGrid.get_grid_width(grid)
    
    end_positions = 
    [
      {{grid_width - 1, grid_len - 1}, :horiz},
      {{grid_width - 1, grid_len - 1}, :vert}
    ]

    Enum.all?(end_positions, fn end_pos -> 
      Enum.find(priority_queue, fn {point, _} -> point == end_pos end) |> elem(1) != :infinity
    end)
  end

  defp get_weight(grid, {to, _to_dir}, {from, _from_dir}) do
    # IO.inspect(to, [label: "to", charlists: :as_lists])
    # IO.inspect(from, [label: "from", charlists: :as_lists])
    {x_to, y_to} = to
    {x_from, y_from} = from

    # Helpers.CalbeGrid.get_by_x_y(grid, x, y)
    # |> String.to_integer()

    #get all coords between to and from, excluding from, including to
    steps = if (x_to == x_from) do
      Enum.map(y_from..y_to, fn y -> {x_to, y} end)
    else
      Enum.map(x_from..x_to, fn x -> {x, y_to} end)
    end
    |> Enum.filter(fn point -> point != from end)
    |> Enum.reduce(0, fn {x, y}, acc -> 
      acc + (Helpers.CalbeGrid.get_by_x_y(grid, x, y) |> String.to_integer())
      
    end)

  end

  def dijkstra(grid, {start_x, start_y}, get_viable_moves, get_should_halt, get_weight) do

    priority_queue = Enum.filter(grid, fn {point, cell} -> 
        point != :util
    end)
    |> Enum.flat_map(fn {point, cell} -> 
        [
          {{point, :horiz}, if point == {start_x, start_y} do 0 else :infinity end}, 
          {{point, :vert}, if point == {start_x, start_y} do 0 else :infinity end}
        ]
    end)
    |> Enum.sort(fn {_, a}, {_, b} -> a < b end)

    Enum.reduce_while(1..200000, %{priority_queue: priority_queue, visited_nodes: %{}, predecessors: %{}}, fn iteration, acc ->

        Helpers.Utils.log_interval(iteration, 100, iteration)

        # IO.inspect(acc, [label: "acc", charlists: :as_lists])

        start_ms = System.monotonic_time(:milliseconds)   

        {current_node, current_node_dist} = Enum.find(acc.priority_queue, fn {key, value} -> 
            acc.visited_nodes[key] == nil && value != :infinity 
        end)
        
        end_ms = System.monotonic_time(:milliseconds)
        diff = end_ms - start_ms
        Helpers.Utils.log_interval(diff, 100, iteration)
        # |> IO.inspect([label: "current_node", charlists: :as_lists])

        viable_neighbors = get_viable_moves.(grid, current_node, acc.predecessors)
        # |> IO.inspect([label: "viable_neighbors", charlists: :as_lists])

        new_priority_queue_and_preds = Enum.reduce(viable_neighbors, {acc.priority_queue, acc.predecessors}, fn neighbor, {acc2, preds} ->
            
            neighbor_dist = Enum.find(acc.priority_queue, fn {key, _} -> key == neighbor end) |> elem(1)  

            if neighbor_dist === :infinity or neighbor_dist > current_node_dist + get_weight.(grid, neighbor, current_node) do

                base_dist = if current_node_dist === :infinity do 0 else current_node_dist end

                filtered_acc2 = acc2 |> Enum.filter(fn {key, _} -> key != neighbor end)

                new_entry = {neighbor, base_dist + get_weight.(grid, neighbor, current_node)}

                new_preds = Map.put(preds, neighbor, current_node)

                {filtered_acc2 ++ [new_entry], new_preds}
            else
                {acc2, preds}
            end
        end)

        new_priority_queue = new_priority_queue_and_preds |> elem(0)
        |> Enum.sort(fn {_, a}, {_, b} -> a < b end)

        new_predecessors = new_priority_queue_and_preds |> elem(1)

        new_visited_nodes = Map.put(acc.visited_nodes, current_node, true)

        should_halt = get_should_halt.(grid, new_priority_queue)

        if should_halt do
            {:halt, {new_priority_queue, new_predecessors}}
        else
            {:cont, %{priority_queue: new_priority_queue, visited_nodes: new_visited_nodes, predecessors: new_predecessors}}
        end

    end)

end

  def part1(_args) do

    input = get_parsed_input()
    |> Helpers.CalbeGrid.visualize_grid()

    grid_len = Helpers.CalbeGrid.get_grid_len(input)
    grid_width = Helpers.CalbeGrid.get_grid_width(input)

    start_pos = {0, 0}
    end_pos = {grid_width - 1, grid_len - 1}

    {pq, preds} = dijkstra(input, start_pos, &get_viable_moves/3, &get_should_halt/2, &get_weight/3)

    ends = Enum.filter(pq, fn {node, _} -> 
      {point, _} = node
      point == end_pos
    end)
    |> IO.inspect([label: "ends", charlists: :as_lists])
    |> Enum.sort(fn {_, a}, {_, b} -> a < b end)
    |> Enum.at(0)
    
    # paths_taken = Enum.map(ends, fn {node, _} -> 
      
    #   Enum.reduce_while(1..1000, [node], fn _iteration, acc -> 

    #     latest_node = Enum.at(acc, -1)
    #     |> IO.inspect([label: "latest_node", charlists: :as_lists])

    #     if latest_node |> elem(0) == start_pos do
    #       {:halt, acc}
    #     else
    #       prev_node = preds[latest_node]
    #       {:cont, acc ++ [prev_node]}
    #     end
       
    #   end)
    #   |> Enum.reverse()

    # end)

  end

  def part2(_args) do

  end

end
