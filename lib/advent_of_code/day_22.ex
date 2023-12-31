defmodule AdventOfCode.Day22 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(22, 2023)

#     input = "1,0,1~1,2,1
# 0,0,2~2,0,2
# 0,2,3~2,2,3
# 0,0,4~0,2,4
# 2,0,5~2,2,5
# 0,1,6~2,1,6
# 1,1,8~1,1,9"

    bricks = String.split(input, "\n", trim: true)
    |> Enum.map(fn brick ->
      split = brick
      |> String.split("~", trim: true)
      |> Enum.map(fn brick ->
        coords = brick
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)

        # x y z
        {Enum.at(coords, 0), Enum.at(coords, 1), Enum.at(coords, 2)}
      end)

      {Enum.at(split, 0), Enum.at(split, 1)}
    end)

  end

  defp get_slice(brick, high_or_low) do
    p1 = brick |> elem(0)
    p2 = brick |> elem(1)

    {x1, y1, z1} = p1
    {x2, y2, z2} = p2

    slice_z = if high_or_low == :high do
     max(z1, z2)
    else
     min(z1, z2)
    end

    Enum.flat_map(x1..x2, fn x ->
      Enum.map(y1..y2, fn y ->
        {x, y, slice_z}
      end)
    end)

  end

  #I'll have 5 whoppers, and... another 5 whoppers
  defp get_does_brick_support_other_brick(brick1, brick2) do
    #determine if brick1 supports brick2
    #brick 1 supports brick 2 if any point on the 3d rectangle made by its 2 corner points is directly below any point on b2

    #brick shape {{x, y, z}, {x, y, z}}

    b1p1 = brick1 |> elem(0)
    b1p2 = brick1 |> elem(1)

    {b1x1, b1y1, b1z1} = b1p1
    {b1x2, b1y2, b1z2} = b1p2

    b2p1 = brick2 |> elem(0)
    b2p2 = brick2 |> elem(1)

    {b2x1, b2y1, b2z1} = b2p1
    {b2x2, b2y2, b2z2} = b2p2

    b1_top_slice = get_slice(brick1, :high)

    b2_bottom_slice = get_slice(brick2, :low)

    if Enum.any?(b1_top_slice, fn {x, y, z} ->
      Enum.any?(b2_bottom_slice, fn {x2, y2, z2} ->
        x == x2 && y == y2 && z == z2 - 1
      end)
    end) do
      true
    else
      false
    end
  end

  defp get_does_any_brick_in_list_support_brick(brick, bricks) do
    Enum.any?(bricks, fn brick2 ->
      get_does_brick_support_other_brick(brick2, brick)
    end)
  end

  defp get_does_brick_support_any_brick_in_list(brick, bricks) do
    Enum.any?(bricks, fn brick2 ->
      get_does_brick_support_other_brick(brick, brick2)
    end)
  end

  defp get_supporters_of_brick(brick, bricks) do
    Enum.filter(bricks, fn brick2 ->
      get_does_brick_support_other_brick(brick2, brick)
    end)
  end

  defp lower_brick_by_n(brick, n) do
    p1 = brick |> elem(0)
    p2 = brick |> elem(1)

    {x1, y1, z1} = p1
    {x2, y2, z2} = p2

    {{x1, y1, z1 - n}, {x2, y2, z2 - n}}
  end

  defp settle_bricks(bricks, should_reverse \\ true) do
    # sort bricks by lowest y to highest y
    sorted = bricks
    |> Enum.sort(fn {a1, a2}, {b1, b2} -> min(a1 |> elem(2), a2 |> elem(2)) <  min(b1 |> elem(2), b2 |> elem(2)) end)
    # |> IO.inspect(label: "sorted")

    settled = Enum.reduce(sorted, [], fn brick, acc ->
      {p1, p2} = brick
      {x1, y1, z1} = p1
      {x2, y2, z2} = p2

      #if y is 1 on either point, it is immediately settled
      if z1 == 1 or z2 == 1 do
        [brick | acc]
      else
        
        # IO.inspect(acc, label: "acc")
        # IO.inspect(brick, label: "brick")

        new_brick = Enum.reduce_while(1..1000, brick, fn n, brick ->
          # IO.inspect(brick, label: "brick_settling")
          if (get_does_any_brick_in_list_support_brick(brick, acc) || brick |> elem(0) |> elem(2) == 1 || brick |> elem(1) |> elem(2) == 1) do
            {:halt, brick}
          else
            {:cont, lower_brick_by_n(brick, 1)}
          end
        end)

        [new_brick | acc]
      end
    end)

    if should_reverse do
      Enum.reverse(settled)
    else
      settled
    end
  end

  def part1(_args) do

    input = get_parsed_input()

    settled = settle_bricks(input)

    support_structure = Enum.reduce(settled, %{}, fn brick, acc ->
      Map.put(acc, brick, get_supporters_of_brick(brick, settled))
    end)
    |> IO.inspect(label: "support_structure")

    bricks_who_are_safe_to_remove = Enum.filter(settled, fn brick ->
      !Enum.any?(support_structure, fn {brick2, supporters} ->
        [brick] == supporters
      end)
    end)
    |> length()

  end

  def part2(_args) do

    input = get_parsed_input()

    settled = settle_bricks(input, false)
    
    IO.puts("settled complete")

    support_structure = Enum.reduce(settled, %{}, fn brick, acc ->
      Map.put(acc, brick, get_supporters_of_brick(brick, settled))
    end)
    |> IO.inspect(label: "support_structure")

    bricks_who_would_fall_if_removed = Enum.reduce(settled, %{}, fn brick, acc ->
      #if 'brick' was removed, how many bricks would then move as a result?

      # IO.inspect(brick, label: "brick")

      #create support structure but without "brick" anywhere in it
      support_structure_without_brick = Enum.reduce(support_structure, %{}, fn {brick2, supporters}, acc ->
        new_supporters = Enum.filter(supporters, fn brick3 ->
          brick3 != brick
        end)

        Map.put(acc, brick2, new_supporters)
      end)
      |> Map.delete(brick)
      # |> IO.inspect(label: "support_structure_without_brick")

      count = Enum.reduce_while(1..1000, support_structure_without_brick, fn i, acc ->
        # find all bricks that are not supported by any other bricks who also don't touch 1 with either z coord. 
        # if none, return halt and length of original support structure minus length of final support structure

        if (i > 999) do
          IO.puts("we hit 999 somthign went wrong lol")
        end

        bricks_that_would_fall = Enum.filter(acc, fn {brick2, supporters} ->
          brick2 |> elem(0) |> elem(2) > 1 
          && brick2 |> elem(1) |> elem(2) > 1 
          && supporters == []
        end)
        |> Enum.map(fn {brick2, supporters} ->
          brick2
        end)
        # |> IO.inspect(label: "bricks_that_would_fall")

        if bricks_that_would_fall == [] do
          {:halt, map_size(support_structure) - map_size(acc)}
        else
          # remove all bricks that would fall from the support structure, both as supporters and as bricks
          new_support_structure = Enum.reduce(acc, %{}, fn {brick2, supporters}, acc2 ->
            new_supporters = Enum.filter(supporters, fn brick3 ->
              !Enum.any?(bricks_that_would_fall, fn brick4 ->
                brick4 == brick3
              end)
            end)

            if !Enum.any?(bricks_that_would_fall, fn brick3 ->
              brick3 == brick2
            end) do
              Map.put(acc2, brick2, new_supporters)
            else
              acc2
            end
          end)
          # |> IO.inspect(label: "new_support_structure")

          {:cont, new_support_structure}
        end
          
        
      end)

      Map.put(acc, brick, count - 1)

      # Map.put(acc, brick, count_bricks_directly_fall + count_bricks_indirectly_fall)

    end)
    |> IO.inspect(label: "bricks_who_would_fall_if_removed")
    |> Enum.reduce(0, fn {brick, count}, acc ->
      acc + count
    end)

  end
end
