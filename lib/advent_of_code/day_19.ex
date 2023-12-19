defmodule AdventOfCode.Day19 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(19, 2023)
   
    input = "px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}"

    [workflows_str, parts_str] = String.split(input, "\n\n", trim: true)

    workflows = String.split(workflows_str, "\n", trim: true)
    |> Enum.reduce(%{}, fn workflow_str, acc ->
      [name, rules_str] = String.split(workflow_str, "{", trim: true)

      rules = String.replace(rules_str, "}", "")
      |> String.split(",", trim: true)

      Map.put(acc, name, rules)

    end)

    parts = String.split(parts_str, "\n", trim: true)
    |> Enum.map(fn part_str ->
     String.replace(part_str, "{", "")
      |> String.replace("}", "")
      |> String.split(",", trim: true)
      |> Enum.reduce(%{}, fn part, acc ->
        [key, value] = String.split(part, "=", trim: true)
        Map.put(acc, key, String.to_integer(value))
      end)

    end)

    {workflows, parts}

  end

  defp process_part_single_workflow(part, workflows, current_workflow_key \\ "in") do

    current_workflow = workflows[current_workflow_key]

    Enum.reduce_while(current_workflow, nil, fn rule, _acc ->
      if !String.contains?(rule, ":") do
        {:halt, rule}
      else
        [property, rest] = if (String.contains?(rule, "<")) do
          String.split(rule, "<", trim: true)
        else
          String.split(rule, ">", trim: true)
        end

        [value, next_workflow_key_route_if_true] = String.split(rest, ":", trim: true)

        operation = if (String.contains?(rule, "<")) do
          fn x, y -> 
            x < y 
          end
        else
          fn x, y -> 
            x > y 
          end
        end


        operation_result = operation.(part[property], String.to_integer(value))

        if (operation_result) do
          {:halt, next_workflow_key_route_if_true}
        else
          {:cont, nil}
        end
      end
    end)
    
  end

  defp process_part_all_workflows(part, workflows) do
    Enum.reduce_while(0..10000, "in", fn _i, acc -> 

      workflow_result = process_part_single_workflow(part, workflows, acc)

      if workflow_result == "R" || workflow_result == "A" do
        {:halt, workflow_result}
      else
        {:cont, workflow_result}
      end
      
    end)
  end

  def part1(_args) do

    input = get_parsed_input()

    {workflows, parts} = input

    Enum.filter(parts, fn part ->
      process_part_all_workflows(part, workflows) == "A"
    end)
    |> Enum.reduce(0, fn part, acc ->
      acc + part["x"] + part["m"] + part["a"] + part["s"]
    end)

  end

  def part2(_args) do
  end
end
