defmodule AdventOfCode.Day17 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(16, 2023)

    input = "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533"

    Helpers.CalbeGrid.parse(input, "\n", "")

  end

  defp get_viable_moves(grid, pos, current_direction, current_num_straight_line) do

    {x, y} = pos

    [
      {{x + 1, y}, :east},
      {{x - 1, y}, :west},
      {{x, y + 1}, :south},
      {{x, y - 1}, :north}
    ]
    |> Enum.filter(fn move -> 
      #move can not be opposite of current direction
      {move_pos, move_direction} = move
      cond do
        current_direction == nil -> true
        current_direction == :east && move_direction == :west -> false
        current_direction == :west && move_direction == :east -> false
        current_direction == :north && move_direction == :south -> false
        current_direction == :south && move_direction == :north -> false
        true -> true
      end
    end)
    |> Enum.filter(fn move ->
      {move_pos, move_direction} = move
      {move_x, move_y} = move_pos
      
      Helpers.CalbeGrid.get_by_x_y(grid, move_x, move_y, nil) != nil
    end)
    |> Enum.filter(fn move ->
      {move_pos, move_direction} = move
      {move_x, move_y} = move_pos
      cond do
        current_direction == nil -> true
        current_num_straight_line > 2 && current_direction == move_direction -> false
        true -> true
      end    
    end)
    |> Enum.map(fn move ->
      {move_pos, move_direction} = move
      {move_x, move_y} = move_pos

      new_num_straight_line = if current_direction == move_direction do current_num_straight_line + 1 else 1 end

      {move_pos, move_direction, new_num_straight_line}
    end)
  end

  defp get_should_halt(grid, priority_queue) do
    
    grid_len = Helpers.CalbeGrid.get_grid_len(grid)
    grid_width = Helpers.CalbeGrid.get_grid_width(grid)
    
    end_pos = {grid_width - 1, grid_len - 1}

    end_dist = Enum.find(priority_queue, fn {point, _} -> point == end_pos end) |> elem(1)

    end_dist != :infinity
  end

  defp get_weight(grid, move) do
    {pos, _, _} = move
    {x, y} = pos

    Helpers.CalbeGrid.get_by_x_y(grid, x, y)
    |> String.to_integer()
  end

  defp get_last_3_from_predecessors(predecessors, pos) do
     #get last 3 predecessors
     prev = Enum.find(predecessors, fn {point, _} -> point == pos end)

     prevprev = Enum.find(predecessors, fn {point, _} -> point == prev end)
 
     prevprevprev = Enum.find(predecessors, fn {point, _} -> point == prevprev end)

     [prev, prevprev, prevprevprev]
  end

  def dijkstra(grid, {start_x, start_y}) do

    priority_queue = Enum.filter(grid, fn {point, cell} -> 
        point != :util
    end)
    |> Enum.flat_map(fn {point, cell} -> 
        {{point, :east, 0}, if point == {start_x, start_y} do 0 else :infinity end}
        {{point, :west, 0}, if point == {start_x, start_y} do 0 else :infinity end}
        {{point, :north, 0}, if point == {start_x, start_y} do 0 else :infinity end}
        {{point, :south, 0}, if point == {start_x, start_y} do 0 else :infinity end}
    end)
    |> Enum.sort(fn {_, a}, {_, b} -> a < b end)

    Enum.reduce_while(1..20000, %{priority_queue: priority_queue, visited_nodes: [], predecessors: %{}}, fn _iteration, acc ->

        {current_node, current_node_dist} = Enum.find(acc.priority_queue, fn {key, _} -> !Enum.member?(acc.visited_nodes, key) end)

        {current_pos, current_direction, current_num_straight_line} = current_node

        viable_neighbors = get_viable_moves(grid, current_pos, current_direction, current_num_straight_line)
        |> IO.inspect(label: "viable_neighbors")

        new_priority_queue_and_preds = Enum.reduce(viable_neighbors, {acc.priority_queue, acc.predecessors}, fn neighbor, {acc2, preds} ->
          
            IO.inspect(acc.priority_queue, label: "acc.priority_queue")
            IO.inspect(neighbor, label: "neighbor")

            neighbor_dist = Enum.find(acc.priority_queue, fn {key, _} -> key == neighbor end) 
            |> IO.inspect(label: "neighbor_dist")
            |> elem(1)  

            {neighbor_pos, neighbor_direction, neighbor_num_straight_line} = neighbor

            if neighbor_dist === :infinity or neighbor_dist > current_node_dist + 1 do

                base_dist = if current_node_dist === :infinity do 0 else current_node_dist end

                filtered_acc2 = acc2 |> Enum.filter(fn {key, _} -> key != neighbor end)

                new_entry = {neighbor, base_dist + get_weight(grid, neighbor)}

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

        should_halt = get_should_halt(grid, new_priority_queue)

        if should_halt do
            {:halt, {new_priority_queue, new_predecessors}}
        else
            {:cont, %{priority_queue: new_priority_queue, visited_nodes: new_visited_nodes, predecessors: new_predecessors}}
        end

    end)

end

  def part1(_args) do

    # notes - need to somehow keep track of the direction we came and the num steps in a straight line we are on as part of the
    # key we store in visited nodes and maybe in preds and in the priority queue

    input = get_parsed_input()
    |> Helpers.CalbeGrid.visualize_grid()

    grid_len = Helpers.CalbeGrid.get_grid_len(input)
    grid_width = Helpers.CalbeGrid.get_grid_width(input)

    start_pos = {0, 0}
    end_pos = {grid_width - 1, grid_len - 1}

    results = dijkstra(input, start_pos)
    # |> elem(0)
    # |> Enum.find(fn {point, _} -> point == end_pos end)

    {priority_queue, predecessors} = results

    #find the full path using the predecessors
    path_took = Enum.reduce_while(0..1000, [end_pos], fn i, acc ->

      first = acc |> List.first()

      if first == start_pos do
        {:halt, acc}
      else
        {:cont, [predecessors |> Map.get(first) | acc]}
      end
    
    end)

    visual = Enum.reduce(path_took, input, fn pos, acc ->
      {x, y} = pos

      Helpers.CalbeGrid.set_by_x_y(acc, x, y, "X")
    end)
    |> Helpers.CalbeGrid.visualize_grid()


  end

  def part2(_args) do
  end
end
