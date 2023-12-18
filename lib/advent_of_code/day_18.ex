defmodule AdventOfCode.Day18 do

  defp get_parsed_input() do
    input = AdventOfCode.Input.get!(18, 2023)
    
#     input = "R 6 (#70c710)
# D 5 (#0dc571)
# L 2 (#5713f0)
# D 2 (#d2c081)
# R 2 (#59c680)
# D 2 (#411b91)
# L 5 (#8ceee2)
# U 2 (#caa173)
# L 1 (#1b58a2)
# U 2 (#caa171)
# R 2 (#7807d2)
# U 3 (#a77fa3)
# L 2 (#015232)
# U 2 (#7a21e3)"

    String.split(input, "\n", trim: true)
    |> Enum.map(fn line ->
      [direction, steps, color_code] = String.split(line, " ", trim: true)
      
      %{
        direction: direction,
        steps: String.to_integer(steps),
        color_code: String.replace(color_code, "(", "") |> String.replace(")", "")
      }
    end)
  end
  
  defp transform_instructions_to_verticies(instructions) do
    
    Enum.reduce(instructions, [{0,0}], fn instruction, acc ->

      {l_x, l_y} = List.last(acc)

      new_vertex = case instruction.direction do
        "R" -> {l_x + instruction.steps, l_y}
        "L" -> {l_x - instruction.steps, l_y}
        "U" -> {l_x, l_y - instruction.steps}
        "D" -> {l_x, l_y + instruction.steps}
      end

      acc ++ [new_vertex]
    end)
  end

  defp calc_area_irregular_polygon(verticies) do
    #  A = 0.5 * |(x1*y2 - x2*y1) + (x2*y3 - x3*y2) + ... + (xn*y1 - x1*yn)| Where A is the area, x and y are the coordinates of the vertices, and n is the number of vertices
    # https://www.linkedin.com/advice/1/how-do-you-calculate-area-perimeter-irregular-polygon#:~:text=To%20calculate%20the%20area%20of,is%20the%20number%20of%20vertices.

    0.5 * abs(
      Enum.with_index(verticies)
      |> Enum.reduce(0, fn {curr_vertex, index}, acc ->

       
          {x1, y1} = curr_vertex
          {x2, y2} = Enum.at(verticies, index + 1, List.first(verticies))
          
  
          acc + (x1 * y2 - x2 * y1)
      end)
    )
  end

  defp get_perimeter(instructions) do
    Enum.reduce(instructions, 0, fn instruction, acc ->
      acc + instruction.steps
    end)
  end


  def part1(_args) do

    input = get_parsed_input()

    verticies = transform_instructions_to_verticies(input)
    |> IO.inspect()

    area = calc_area_irregular_polygon(verticies)

    perimeter = get_perimeter(input)

    area + (perimeter * 0.5) + 1

  end

  def part2(_args) do
  end
end
