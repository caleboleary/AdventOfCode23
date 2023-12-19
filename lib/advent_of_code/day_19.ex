defmodule AdventOfCode.Day19 do

  defp get_parsed_input() do 

    input = AdventOfCode.Input.get!(19, 2023)
   
#     input = "px{a<2006:qkq,m>2090:A,rfg}
# pv{a>1716:R,A}
# lnx{m>1548:A,A}
# rfg{s<537:gd,x>2440:R,A}
# qs{s>3448:A,lnx}
# qkq{x<1416:A,crn}
# crn{x>2662:A,R}
# in{s<1351:px,qqz}
# qqz{s>2770:qs,m<1801:hdj,R}
# gd{a>3333:R,R}
# hdj{m>838:A,pv}

# {x=787,m=2655,a=1222,s=2876}
# {x=1679,m=44,a=2067,s=496}
# {x=2036,m=264,a=79,s=2244}
# {x=2461,m=1339,a=466,s=291}
# {x=2127,m=1623,a=2188,s=1013}"


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

  defp get_all_possible_paths(workflows) do

    Enum.reduce_while(0..10000, [[{"in", nil}]], fn _i, acc -> 

      # IO.inspect(acc, label: "acc")

      #find a random unfinished path
      unfinished_path = Enum.find(acc, fn path -> 
        {last_item, last_item_index} = List.last(path)
        last_item != "R" && last_item != "A"
      end)

      #if there are no unfinished paths, we are done
      if unfinished_path == nil do
        {:halt, acc}
      else
        {last_item, last_item_index} = List.last(unfinished_path)

        workflow = workflows[last_item]

        possible_next_steps = Enum.with_index(workflow)
        |> Enum.filter(fn {rule, index} ->
          String.contains?(rule, ":")
        end)
        |> Enum.map(fn {rule, index} ->
          step_id = String.split(rule, ":", trim: true)
          |> List.last()
          {step_id, index}
        end)

        possible_next_steps = possible_next_steps ++ [{Enum.at(workflow, -1), length(workflow) - 1}]

        {:cont, Enum.filter(acc, fn path -> path != unfinished_path end) ++ Enum.map(possible_next_steps, fn step -> 
          unfinished_path ++ [step]
        end)}
      end
      
    end)

  end

  defp get_restrictions_on_parts_who_follow_path(path, workflows) do

    base_spec = %{
      "x_min" => 1,
      "x_max" => 4000,
      "m_min" => 1,
      "m_max" => 4000,
      "a_min" => 1,
      "a_max" => 4000,
      "s_min" => 1,
      "s_max" => 4000
    }

    Enum.with_index(path)
    |> Enum.reduce(base_spec, fn {{workflow_key, workflow_index}, index}, acc ->

      workflow = workflows[workflow_key]
      next = Enum.at(path, index + 1)

      if (next == nil) do
        acc
      else
        {next_step, next_step_index} = next

        Enum.with_index(workflow)
        |> Enum.reduce_while(acc, fn {rule, curr_workflow_index}, acc2 -> 
          
          if (
            !String.contains?(rule, ":")
            #attepting to handle cases like lnx{m>1548:A,A} where over or under both result in same thing
            # thinking out loud, what if we had something like asdf{m>100:abc, m>10: A, abc}
            # I think my current code would dedupe the 2 abc paths and not consider the second abc default....
            #|| (rule == Enum.at(workflow, -2) && String.split(rule, ":", trim: true) |> List.last() == Enum.at(workflow, -1))
            ) do
            {:halt, acc2}
          else
            [property, rest] = if (String.contains?(rule, "<")) do
              String.split(rule, "<", trim: true)
            else
              String.split(rule, ">", trim: true)
            end
    
            [value, next_workflow_key_route_if_true] = String.split(rest, ":", trim: true)
  
            if (curr_workflow_index == next_step_index) do
  
              # we want to true from this operation
              new_acc = if (String.contains?(rule, "<")) do
                Map.put(acc2, "#{property}_max", min(String.to_integer(value) - 1, acc2["#{property}_max"]))
              else
                Map.put(acc2, "#{property}_min", max(String.to_integer(value) + 1, acc2["#{property}_min"]))
              end
  
              {:halt, new_acc}
            else
  
              # we want to flase from this operation as we are not yet to our destination in this workflow.
              new_acc = if (String.contains?(rule, "<")) do
                Map.put(acc2, "#{property}_min", max(String.to_integer(value), acc2["#{property}_min"]))
              else
                Map.put(acc2, "#{property}_max", min(String.to_integer(value), acc2["#{property}_max"]))
              end
  
              {:cont, new_acc}
            end
          end
        end)
      end

    end)
    
  end

  defp get_unique_parts_from_spec(spec) do
    (spec["x_max"] - spec["x_min"] + 1) * (spec["m_max"] - spec["m_min"] + 1) * (spec["a_max"] - spec["a_min"] + 1) * (spec["s_max"] - spec["s_min"] + 1)
  end

  def part2(_args) do

    input = get_parsed_input()

    {workflows, _parts} = input

    possible_paths = get_all_possible_paths(workflows)
    |> Enum.filter(fn path -> 
      {last_step, _last_index} = List.last(path)
      last_step == "A"
    end)


    Enum.map(possible_paths, fn path ->
      spec = get_restrictions_on_parts_who_follow_path(path, workflows)
      
      get_unique_parts_from_spec(spec)
    end)
    |> Enum.sum()
  end
end
