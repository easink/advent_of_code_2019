defmodule Day02 do
  @moduledoc """
  Documentation for Day02.
  """

  def reset_data() do
    [
      1,
      # 0
      12,
      # 0
      2,
      3,
      1,
      1,
      2,
      3,
      1,
      3,
      4,
      3,
      1,
      5,
      0,
      3,
      2,
      1,
      6,
      19,
      1,
      19,
      5,
      23,
      2,
      13,
      23,
      27,
      1,
      10,
      27,
      31,
      2,
      6,
      31,
      35,
      1,
      9,
      35,
      39,
      2,
      10,
      39,
      43,
      1,
      43,
      9,
      47,
      1,
      47,
      9,
      51,
      2,
      10,
      51,
      55,
      1,
      55,
      9,
      59,
      1,
      59,
      5,
      63,
      1,
      63,
      6,
      67,
      2,
      6,
      67,
      71,
      2,
      10,
      71,
      75,
      1,
      75,
      5,
      79,
      1,
      9,
      79,
      83,
      2,
      83,
      10,
      87,
      1,
      87,
      6,
      91,
      1,
      13,
      91,
      95,
      2,
      10,
      95,
      99,
      1,
      99,
      6,
      103,
      2,
      13,
      103,
      107,
      1,
      107,
      2,
      111,
      1,
      111,
      9,
      0,
      99,
      2,
      14,
      0,
      0
    ]
  end

  def part1() do
    reset_data() |> opcode()
  end

  def part1_test1() do
    q = [1, 0, 0, 0, 99]
    [2, 0, 0, 0, 99] = opcode(q)
    q = [2, 3, 0, 3, 99]
    [2, 3, 0, 6, 99] = opcode(q)
    q = [2, 4, 4, 5, 99, 0]
    [2, 4, 4, 5, 99, 9801] = opcode(q)
    q = [1, 1, 1, 4, 99, 5, 6, 0, 99]
    [30, 1, 1, 4, 2, 5, 6, 0, 99] = opcode(q)
    2_692_315 = hd(reset_data() |> opcode())
  end

  def part2() do
    tests = for noun <- 0..99, verb <- 0..99, do: {noun, verb}
    {noun, verb} = Enum.find(tests, &part2_test(&1))
    100 * noun + verb
  end

  def part2_test({noun, verb}) do
    19_690_720 ==
      reset_data()
      |> set_noun(noun)
      |> set_verb(verb)
      |> opcode()
      |> Kernel.hd()
  end

  def part2_test1() do
    data =
      reset_data()
      |> set_noun(12)
      |> set_verb(2)
      |> opcode()

    # noun = get(data, 1)
    # verb = get(data, 2)
    1202 = hd(data)
  end

  def opcode(data), do: opcode(data, data, 0)

  def opcode([1, pos1, pos2, respos | _rest], data, pos) do
    {op_data, data, pos} = op(pos1, pos2, respos, &(&1 + &2), data, pos)
    opcode(op_data, data, pos)
  end

  def opcode([2, pos1, pos2, respos | _rest], data, pos) do
    {op_data, data, pos} = op(pos1, pos2, respos, &(&1 * &2), data, pos)
    opcode(op_data, data, pos)
  end

  def opcode([99 | _rest], data, _pos) do
    data
  end

  defp get(data, pos), do: Enum.at(data, pos)
  defp set(data, pos, val), do: List.replace_at(data, pos, val)

  defp op(pos1, pos2, respos, fun, data, pos) do
    arg1 = get(data, pos1)
    arg2 = get(data, pos2)
    res = fun.(arg1, arg2)
    data = set(data, respos, res)

    pos = pos + 4
    op_data = Enum.slice(data, pos, 4)

    {op_data, data, pos}
  end

  defp set_noun(data, val) do
    List.replace_at(data, 1, val)
  end

  defp set_verb(data, val) do
    List.replace_at(data, 2, val)
  end
end
