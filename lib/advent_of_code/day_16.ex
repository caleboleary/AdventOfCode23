defmodule AdventOfCode.Day16 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(16, 2023)

   
#     input = ".|...\\....
# |.-.\\.....
# .....|-...
# ........|.
# ..........
# .........\\
# ..../.\\\\..
# .-.-/..|..
# .|....-|.\\
# ..//.|...."

    Helpers.CalbeGrid.parse(input, "\n", "")
  end

  defp get_next_step(grid, {curr_x, curr_y, curr_dir}) do
    # takes in x and y that light is in, and direction it's moving
    # returns a List of new x,y,dir that this will produce

    case curr_dir do
      :north -> 
        case Helpers.CalbeGrid.get_by_x_y(grid, curr_x, curr_y - 1) do
          "." -> 
           [{curr_x, curr_y - 1, :north}]
          "|" -> 
            [{curr_x, curr_y - 1, :north}]           
          "-" -> 
           [
              {curr_x, curr_y - 1, :east},
              {curr_x, curr_y - 1, :west}
           ]
          "/" -> 
            [{curr_x, curr_y - 1, :east}]    
          "\\" ->
            [{curr_x, curr_y - 1, :west}]
          nil ->
            []
        end
      :east -> 
        case Helpers.CalbeGrid.get_by_x_y(grid, curr_x + 1, curr_y) do
          "." -> 
           [{curr_x + 1, curr_y, :east}]
          "|" -> 
            [
              {curr_x + 1, curr_y, :north},
              {curr_x + 1, curr_y, :south}
            ]
          "-" -> 
            [{curr_x + 1, curr_y, :east}]           
          "/" -> 
            [{curr_x + 1, curr_y, :north}]    
          "\\" ->
            [{curr_x + 1, curr_y, :south}]
          nil ->
            []
        end
      :south -> 
        case Helpers.CalbeGrid.get_by_x_y(grid, curr_x, curr_y + 1) do
          "." -> 
           [{curr_x, curr_y + 1, :south}]
          "|" -> 
            [{curr_x, curr_y + 1, :south}]           
          "-" -> 
           [
              {curr_x, curr_y + 1, :east},
              {curr_x, curr_y + 1, :west}
           ]
          "/" -> 
            [{curr_x, curr_y + 1, :west}]    
          "\\" ->
            [{curr_x, curr_y + 1, :east}]
          nil ->
            []
        end
      :west -> 
        case Helpers.CalbeGrid.get_by_x_y(grid, curr_x - 1, curr_y) do
          "." -> 
            [{curr_x - 1, curr_y, :west}]
          "|" -> 
            [
              {curr_x - 1, curr_y, :north},
              {curr_x - 1, curr_y, :south}
            ]
          "-" -> 
            [{curr_x - 1, curr_y, :west}]           
          "/" -> 
            [{curr_x - 1, curr_y, :south}]    
          "\\" ->
            [{curr_x - 1, curr_y, :north}]
          nil ->
            []
        end
        
    end

  end

  def get_energy(grid, entry) do
    max_sim_steps = 200000

    default_acc = %{
      energy: [],
      paths: [%{path: [entry], terminated: false}]
    }

    results = Enum.reduce_while(0..max_sim_steps, default_acc, fn step, acc ->
      # IO.inspect(step, label: "step")

      energy = acc[:energy]
      paths = acc[:paths]

      #find an un-terminated path
      un_terminated_path = Enum.find(paths, fn path -> !path.terminated end)

      if un_terminated_path == nil do
        {:halt, %{energy: energy, paths: paths}}
      else
        #get the last step of that path
        last_step = List.last(un_terminated_path.path)
        # |> IO.inspect(label: "last_step")

        # IO.inspect(Helpers.CalbeGrid.get_by_x_y(grid, last_step |> elem(0), last_step |> elem(1)), label: "last_step_cell")

        #get the next steps
        # next_steps = memoized(last_step, fn -> 
         next_steps = get_next_step(grid, last_step)
          |> Enum.filter(fn {x, y, dir} -> 
            Enum.member?(un_terminated_path.path, {x, y, dir}) == false
          end)
        # end)
        # |> IO.inspect(label: "next_steps")

        #if there are no next steps, terminate the path
        if next_steps == [] do
          # IO.inspect("a path is terminating")
          # IO.inspect(un_terminated_path, label: "un_terminated_path")
          filtered_paths = Enum.filter(paths, fn path -> path != un_terminated_path end)

          new_paths = [%{path: un_terminated_path.path, terminated: true}] ++ filtered_paths

          {:cont, %{energy: energy, paths: new_paths}}
        else
          #otherwise, add the next steps to the path
          filtered_paths = Enum.filter(paths, fn path -> path != un_terminated_path end)

          adding_paths = Enum.map(next_steps, fn next_step -> 

            #does any terminated path contain this exact next step? 
            own_footsteps = Enum.find(filtered_paths, fn path -> 
              path.terminated == true and Enum.member?(path[:path], next_step)
            end)

            if (own_footsteps != nil) do
              new_path = un_terminated_path.path ++ Enum.slice(own_footsteps[:path], 0, Enum.find_index(own_footsteps[:path], fn own_step -> 
                own_step == next_step
              end) + 1)
              %{path: new_path, terminated: true}
            else
              %{path: un_terminated_path.path ++ [next_step], terminated: false}
            end

          end)

          new_paths = adding_paths ++ filtered_paths

          # #mark all non terminated paths as terminated if they have more than 500 steps
          # new_paths = Enum.map(new_paths, fn path -> 
          #   if path.terminated == false and length(path.path) > 1000 do
          #     %{path: path.path, terminated: true}
          #   else
          #     path
          #   end
          # end)

          new_energy = energy ++ next_steps 
          |> Enum.uniq_by(fn {x, y, dir} -> {x, y} end)

          {:cont, %{energy: new_energy, paths: new_paths}}
        end
      end
    end)

    length(results[:energy])
    

  end

  def part1(_args) do

    grid = get_parsed_input()
    |> Helpers.CalbeGrid.visualize_grid()

    entry = {3, -1, :south}
    # entry = {-1, 0, :east}

    energy = get_energy(grid, entry)    

  end

  def part2(_args) do
    # 8231 wrong

    grid = get_parsed_input()
    |> Helpers.CalbeGrid.visualize_grid()

    grid_width = Helpers.CalbeGrid.get_grid_width(grid)
    grid_len = Helpers.CalbeGrid.get_grid_len(grid)

    entries_from_north = Enum.map(0..(grid_width - 1), fn x -> 
      {x, -1, :south}
    end)

    entries_from_south = Enum.map(0..(grid_width - 1), fn x -> 
      {x, grid_len, :north}
    end)

    entries_from_east = Enum.map(0..(grid_len - 1), fn y -> 
      {grid_width, y, :west}
    end)

    entries_from_west = Enum.map(0..(grid_len - 1), fn y -> 
      {-1, y, :east}
    end)

    entries = entries_from_north ++ entries_from_south ++ entries_from_east ++ entries_from_west

    IO.inspect(length(entries), label: "length of entries")

    energy = Enum.with_index(entries)
    |> Enum.map(fn {entry, index} -> 
      IO.inspect(index, label: "searching entry")
      IO.inspect(entry, label: "entry")
      get_energy(grid, entry)
      |> IO.inspect(label: "energy")
    end)

    max_energy = Enum.max(energy)
    
  end

    # https://github.com/michaelst/aoc/blob/main/lib/advent_of_code/day_12.ex
    defp memoized(key, fun) do
      with nil <- Process.get(key) do
        fun.() |> tap(&Process.put(key, &1))
      end
    end
end
