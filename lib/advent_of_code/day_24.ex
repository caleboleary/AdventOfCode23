defmodule AdventOfCode.Day24 do
  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(24, 2023)

#     input = "19, 13, 30 @ -2,  1, -2
# 18, 19, 22 @ -1, -1, -2
# 20, 25, 34 @ -2, -2, -4
# 12, 31, 28 @ -1, -2, -1
# 20, 19, 15 @  1, -5, -3"

# input = "19, 13, 30 @ 1, 0, -4
# 18, 19, 22 @ 2, -2, -4
# 20, 25, 34 @ 1, -3, -6
# 12, 31, 28 @ 2, -3, -3
# 20, 19, 15 @ 4, -6, -5"

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

    if ((ray1_end[:x] - ray1_coords[:x]) == 0 || (ray2_end[:x] - ray2_coords[:x]) == 0) do
      {:infinity, :infinity}

    else

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
  
        IO.inspect(int, label: "int for #{inspect({ray1_coords, ray1_velocity})} and #{inspect({ray2_coords, ray2_velocity})}")
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
        do: {:history, :history}, else: int
      end
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

        if intersection == {:infinity, :infinity} || intersection == {:history, :history} do
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

  defp transform_input_by_velocity(rays, velocity) do
    Enum.map(rays, fn ray -> 
      {coords, {x, y, z}} = ray

      {x_v, y_v, z_v} = velocity

      modified_velocity = {x + (x_v * -1), y + (y_v * -1), z + (z_v * -1)}

      {coords, modified_velocity}
    end)
  end

  defp get_impossible_x_ranges(input) do
    Enum.reduce(input, [], fn ray, acc ->
      {coords0, velocity0} = ray
      {px0, py0, pz0} = coords0
      {vx0, vy0, vz0} = velocity0

      rays_without_ray = Enum.filter(input, fn other_ray -> other_ray != ray end)

      rng = Enum.map(rays_without_ray, fn other_ray ->
        {coords1, velocity1} = other_ray
        {px1, py1, pz1} = coords1
        {vx1, vy1, vz1} = velocity1

        if (px0 > px1 && vx0 > vx1) || (px0 < px1 && vx0 < vx1) do
          vx1
        else
          nil
        end

      end)
      |> Enum.filter(fn x -> x != nil end)

      sorted = Enum.sort(rng)
      |> IO.inspect(label: "sorted")

      range = if Enum.count(sorted) > 0 do
        Enum.at(sorted, 0)..Enum.at(sorted, -1)
      else
        nil
      end

      acc ++ [range]

      
    end)
  end

  defp get_impossible_y_ranges(input) do
    Enum.reduce(input, [], fn ray, acc ->
      {coords0, velocity0} = ray
      {px0, py0, pz0} = coords0
      {vx0, vy0, vz0} = velocity0

      rays_without_ray = Enum.filter(input, fn other_ray -> other_ray != ray end)

      rng = Enum.map(rays_without_ray, fn other_ray ->
        {coords1, velocity1} = other_ray
        {px1, py1, pz1} = coords1
        {vx1, vy1, vz1} = velocity1

        if (py0 > py1 && vy0 > vy1) || (py0 < py1 && vy0 < vy1) do
          vy1
        else
          nil
        end

      end)
      |> Enum.filter(fn x -> x != nil end)

      sorted = Enum.sort(rng)
      |> IO.inspect(label: "sorted")

      range = if Enum.count(sorted) > 0 do
        Enum.at(sorted, 0)..Enum.at(sorted, -1)
      else
        nil
      end

      acc ++ [range]

      
    end)
  end
  
  defp get_ray_intersection3d({ray1_coords, ray1_velocity}, {ray2_coords, ray2_velocity}) do
    # thanks roblox forum lol 
    # https://devforum.roblox.com/t/2-line-intersection/407561/3
    # function intersection_point(line_1_start, line_1_end, line_2_start, line_2_end)
    #     local line_1_m = (line_1_end.Z - line_1_start.Z) / (line_1_end.X - line_1_start.X)
    #     local line_2_m = (line_2_end.Z - line_2_start.Z) / (line_2_end.X - line_2_start.X)
    #     local line_1_b = line_1_start.Z - (line_1_m * line_1_start.X)
    #     local line_2_b = line_2_start.Z - (line_2_m * line_2_start.X)
    #     local intersect_x = (line_2_b - line_1_b) / (line_1_m - line_2_m)
    #     local intersect_z = (line_1_m * intersect_x) + line_1_b
    #     return Vector3.new(intersect_x, line_1_start.Y, intersect_z)
    # end

    a_long_distance = 1000000000000000

    ray1_end = follow_ray_n_steps({ray1_coords, ray1_velocity}, a_long_distance) |> tuple_to_map()
    ray2_end = follow_ray_n_steps({ray2_coords, ray2_velocity}, a_long_distance) |> tuple_to_map()

    ray1_coords = tuple_to_map(ray1_coords)
    ray2_coords = tuple_to_map(ray2_coords)

    if ((ray1_end[:x] - ray1_coords[:x]) == 0 || (ray2_end[:x] - ray2_coords[:x]) == 0) do
      {:infinity, :infinity, :infinity}

    else

      ray1_m = (ray1_end[:z] - ray1_coords[:z]) / (ray1_end[:x] - ray1_coords[:x])
      ray2_m = (ray2_end[:z] - ray2_coords[:z]) / (ray2_end[:x] - ray2_coords[:x])
      ray1_b = ray1_coords[:z] - (ray1_m * ray1_coords[:x])
      ray2_b = ray2_coords[:z] - (ray2_m * ray2_coords[:x])
      
      int = if ((ray1_m - ray2_m) == 0) do
        # parallel
        {:infinity, :infinity, :infinity}
      else
        intersect_x = (ray2_b - ray1_b) / (ray1_m - ray2_m)
        intersect_z = (ray1_m * intersect_x) + ray1_b
    
        int = {intersect_x, ray1_coords[:y], intersect_z}
  
        # IO.inspect(int, label: "int for #{inspect({ray1_coords, ray1_velocity})} and #{inspect({ray2_coords, ray2_velocity})}")
      end
  
      ray1_velocity = tuple_to_map(ray1_velocity)
      ray2_velocity = tuple_to_map(ray2_velocity)
  
      if int == {:infinity, :infinity, :infinity} do
        {:infinity, :infinity, :infinity}
      else
        direction = fn velocity -> if velocity > 0, do: 1, else: -1 end
        in_past = fn (coord, velocity, int_coord) -> 
          dv = direction.(velocity)
          (dv > 0 and int_coord < coord) or (dv < 0 and int_coord > coord) 
        end
        
        if Enum.any?([
            in_past.(ray1_coords[:x], ray1_velocity[:x], elem(int, 0)),
            in_past.(ray1_coords[:z], ray1_velocity[:z], elem(int, 2)),
            in_past.(ray2_coords[:x], ray2_velocity[:x], elem(int, 0)),
            in_past.(ray2_coords[:z], ray2_velocity[:z], elem(int, 2))
          ]),
        do: {:history, :history, :history}, else: int

      end

    end

  end

  def part2(_args) do

    part2_old(_args)

    # velocity = {131, -259, 102}

    # input = get_parsed_input()

    # first_ray = Enum.at(input, 0)
    # |> IO.inspect(label: "first_ray")

    # # log ray's position every step for 100 steps
    # Enum.reduce(0..100, [], fn step, acc ->
    #   first = follow_ray_n_steps(first_ray, step * 100000000000) |> tuple_to_map() |> IO.inspect(label: "step #{step}")

    #   second = follow_ray_n_steps({{218159652637142, 441968877324085, 348158644025623 }, velocity}, step * 100000000000) |> tuple_to_map() |> IO.inspect(label: "source step #{step}")

    #   manhattan_dist = abs(first[:x] - second[:x]) + abs(first[:y] - second[:y]) + abs(first[:z] - second[:z])
    #   |> IO.inspect(label: "manhattan_dist")
    # end)
  end

  # I think z is 102 after running this
  def part2_z(_args) do

    input = get_parsed_input()

    vx = 131
    vy = -259

    z_range = -299..300

    Enum.reduce_while(z_range, nil, fn z, _ ->
      IO.inspect(z)
      modified_input = transform_input_by_velocity(input, {vx, vy, z})

      points = (Enum.reduce_while(modified_input, [], fn ray, acc ->

        if (length(acc) > 35) do
          {:halt, acc}
        else
          other_rays = Enum.filter(modified_input, fn other_ray -> other_ray != ray end)
    
          intersections = Enum.reduce(other_rays, [], fn other_ray, acc ->
            # IO.inspect({ray, other_ray})
            intersection = get_ray_intersection3d(ray, other_ray)
    
            if intersection == {:infinity, :infinity, :infinity} || intersection == {:history, :history, :history} do
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
    
          {:cont, acc ++ intersections}
        end
        
      end))
      |> Enum.map(fn intersection -> 
        intersection[:intersection]
      end)
      |> Enum.uniq()

      if Enum.count(points) < 35 do
        IO.inspect(points, label: "points")
        {:halt, z}
      else
        {:cont, nil}
      end

    end)

  end

  # this old part 2 got me here:
  # my final answer x is  21815965263714n,
  # my final answer y is  44196887732408n
  # where n I'm not sure because math errors at large scale.
  # my final velocity is {131, -259, n}
  def part2_old(_args) do

    muh_range = -500..500 
    |> Enum.to_list()
    |> Enum.filter(fn x -> x != 0 end)

    input = get_parsed_input()

    impossible_x = get_impossible_x_ranges(input)
    |> Enum.filter(fn x -> x != nil end)
    |> IO.inspect(label: "impossible_x")

    x_range = muh_range
    # filter out the ones that are impossible
    |> Enum.filter(fn x -> 
      !Enum.any?(impossible_x, fn range -> 
        # IO.inspect({x, range.first, range.last})
        # IO.inspect(x > range.first && x < range.last)
        x > range.first && x < range.last
      end)
    end)
    |> IO.inspect(label: "x_range")
     
    IO.inspect(Enum.count(x_range))

    impossible_y = get_impossible_y_ranges(input)
    |> Enum.filter(fn x -> x != nil end)

    y_range = muh_range
    # filter out the ones that are impossible
    |> Enum.filter(fn y -> 
      !Enum.any?(impossible_y, fn range -> 
        # IO.inspect({y, range.first, range.last})
        # IO.inspect(y > range.first && y < range.last)
        y > range.first && y < range.last
      end)
    end)


    #loop from 0 to 100 for x, y, and z
    z_range = 0..1


    # velocity = {131, -259, 102}
    x_range = 131..131
    y_range = -259..-259
    z_range = 102..102

    Enum.reduce_while(x_range, nil, fn x, _ ->
      res_y = Enum.reduce_while(y_range, nil, fn y, _ ->
        res_z = Enum.reduce_while(z_range, nil, fn z, _ ->
          IO.inspect({x, y, z})

          modified_input = transform_input_by_velocity(input, {x, y, z})
          
          points = (Enum.reduce_while(modified_input, [], fn ray, acc ->

            if (length(acc) > 50) do
              {:halt, acc}
            else
              other_rays = Enum.filter(modified_input, fn other_ray -> other_ray != ray end)
      
              intersections = Enum.reduce(other_rays, [], fn other_ray, acc ->
                # IO.inspect({ray, other_ray})
                intersection = get_ray_interection2d(ray, other_ray)
        
                if intersection == {:infinity, :infinity} || intersection == {:history, :history} do
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
        
              {:cont, acc ++ intersections}
            end
            
          end))
          |> Enum.map(fn intersection -> 
            intersection[:intersection]
          end)
          |> Enum.uniq()

          if Enum.count(points) < 50 do
            IO.inspect(points, label: "points")
            {:halt, {x, y, z}}
          else
            {:cont, nil}
          end

        end)

        if (res_z == nil) do
          {:cont, nil}
        else
          {:halt, res_z}
        end
      end)

      if (res_y == nil) do
        {:cont, nil}
      else
        {:halt, res_y}
      end
    end)
    

  end
end
