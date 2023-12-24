defmodule AdventOfCode.Day24 do
  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(24, 2023)

#     input = "19, 13, 30 @ -2,  1, -2
# 18, 19, 22 @ -1, -1, -2
# 20, 25, 34 @ -2, -2, -4
# 12, 31, 28 @ -1, -2, -1
# 20, 19, 15 @  1, -5, -3"

    split = String.split(input, "\n", trim: true)
    |> Enum.map(fn line ->
      [coords_str, velocity_str] = String.split(line, "@", trim: true)
      
      coords = coords_str
      |> String.split(",", trim: true)
      |> Enum.map(fn coord -> String.trim(coord) |> String.to_integer() end)
      |> List.to_tuple()

      velocity = velocity_str
      |> String.split(",", trim: true)
      |> Enum.map(fn coord -> String.trim(coord) |> String.to_integer() end)
      |> List.to_tuple()
      
      {coords, velocity}

    end)

  end

  defp follow_ray_n_steps({coords, velocity}, n) do
    {x, y, z} = coords
    {vx, vy, vz} = velocity

    {x + vx * n, y + vy * n, z + vz * n}
  end

  defp tuple_to_map({x, y, z}) do
    %{
      x: x,
      y: y,
      z: z
    }
  end
  
  defp get_ray_interection2d({ray1_coords, ray1_velocity}, {ray2_coords, ray2_velocity}) do
    # IO.inspect({ray1_coords, ray1_velocity})
    # IO.inspect({ray2_coords, ray2_velocity})
    
    a_long_distance = 1000000000000000

    ray1_end = follow_ray_n_steps({ray1_coords, ray1_velocity}, a_long_distance) |> tuple_to_map()
    ray2_end = follow_ray_n_steps({ray2_coords, ray2_velocity}, a_long_distance) |> tuple_to_map()

    ray1_coords = tuple_to_map(ray1_coords)
    ray2_coords = tuple_to_map(ray2_coords)

    # thanks roblox forum lol 
    # https://devforum.roblox.com/t/2-line-intersection/407561/3
    ray1_m = (ray1_end[:y] - ray1_coords[:y]) / (ray1_end[:x] - ray1_coords[:x])
    ray2_m = (ray2_end[:y] - ray2_coords[:y]) / (ray2_end[:x] - ray2_coords[:x])
    ray1_b = ray1_coords[:y] - (ray1_m * ray1_coords[:x])
    ray2_b = ray2_coords[:y] - (ray2_m * ray2_coords[:x])
    
    int = if ((ray1_m - ray2_m) == 0) do
      # parallel
      {:infinity, :infinity}
    else
      intersect_x = (ray2_b - ray1_b) / (ray1_m - ray2_m)
      intersect_y = (ray1_m * intersect_x) + ray1_b
  
      int = {intersect_x, intersect_y}

      # IO.inspect(int, label: "int for #{inspect({ray1_coords, ray1_velocity})} and #{inspect({ray2_coords, ray2_velocity})}")
    end

    ray1_velocity = tuple_to_map(ray1_velocity)
    ray2_velocity = tuple_to_map(ray2_velocity)

    if int == {:infinity, :infinity} do
      {:infinity, :infinity}
    else
      direction = fn velocity -> if velocity > 0, do: 1, else: -1 end
      in_past = fn (coord, velocity, int_coord) -> 
        dv = direction.(velocity)
        (dv > 0 and int_coord < coord) or (dv < 0 and int_coord > coord) 
      end
      
      if Enum.any?([
          in_past.(ray1_coords[:x], ray1_velocity[:x], elem(int, 0)),
          in_past.(ray1_coords[:y], ray1_velocity[:y], elem(int, 1)),
          in_past.(ray2_coords[:x], ray2_velocity[:x], elem(int, 0)),
          in_past.(ray2_coords[:y], ray2_velocity[:y], elem(int, 1))
        ]),
      do: {:infinity, :infinity}, else: int
    end
    
  end
    
  defp get_is_point_in_bounds2d({x, y}, {x1, y1}, {x2, y2}) do
    x_in_bounds = x >= x1 && x <= x2
    y_in_bounds = y >= y1 && y <= y2

    x_in_bounds && y_in_bounds
  end

  def part1(_args) do

    input = get_parsed_input()

    (Enum.reduce(input, [], fn ray, acc ->

      other_rays = Enum.filter(input, fn other_ray -> other_ray != ray end)

      intersections = Enum.reduce(other_rays, [], fn other_ray, acc ->
        intersection = get_ray_interection2d(ray, other_ray)

        if intersection == {:infinity, :infinity} do
          acc
        else
          acc ++ [
            %{ 
              ray1: ray,
              ray2: other_ray,
              intersection: intersection
            }
          ]
        end
      end)

      intersections_in_bounds = Enum.filter(
        intersections, 
        fn intersection -> get_is_point_in_bounds2d(
          intersection[:intersection], 
          # {7, 7},
          # {27, 27}
          {200000000000000, 200000000000000}, 
          {400000000000000, 400000000000000}
        ) 
      end)

      acc ++ intersections_in_bounds
      
    end))
    |> Enum.uniq_by(fn intersection -> 
      #unique by the two rays
      [intersection[:ray1], intersection[:ray2]] |> Enum.sort()
    end)
    |> IO.inspect(label: "intersections")
    |> Enum.count()


  end

  def part2(_args) do
  end
end
