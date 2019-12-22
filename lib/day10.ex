defmodule Day10 do
  @moduledoc """
  Documentation for Day10.
  """

  def part1() do
    field =
      astroid_field_input()
      |> parse_field()

    best =
      best_astroid(field)
      |> IO.inspect(label: "best")

    max = max_position(field)

    visibles(field, best, max)
    |> Enum.count()
  end

  def part2() do
    best = {29, 28}

    {x, y} =
      astroid_field_input()
      |> parse_field()
      |> find_nth_asteroid(best, 200 - 1)
      |> elem(2)

    x * 100 + y
  end

  def find_nth_asteroid(field_left, best, n) do
    visibles =
      field_left
      |> Enum.map(fn astroid -> angle_dist(best, astroid) end)
      |> Enum.sort()
      |> Enum.dedup_by(fn {angle, _dist, _orig} -> angle end)

    if Enum.count(visibles) > n do
      Enum.at(visibles, n)
    else
      left = field_left -- visibles
      find_nth_asteroid(left, best, n - Enum.count(visibles))
    end
  end

  def angle_dist({x, y}, {a, b}) do
    # {delta_x, delta_y} = divided(a - x, b - y)
    {dx, dy} = {a - x, b - y}

    angle =
      cond do
        dx >= 0 and dy < 0 -> my_atan2(dx, -dy)
        dx > 0 -> my_atan2(dy, dx) + 90
        dy > 0 -> my_atan2(-dx, dy) + 180
        true -> my_atan2(-dy, -dx) + 270
      end

    dist = dx * dx + dy * dy
    {angle, dist, {a, b}}
  end

  def my_atan2(a, b), do: :math.atan2(a, b) * 180 / :math.pi()

  # def print(screen, x) do
  #   # screen
  #   # |> Enum.map(&int_to_col/1)
  #   # |> Enum.chunk_every(x)
  #   # |> Enum.map(&Enum.join/1)
  #   # |> Enum.join("\n")
  #   # |> IO.puts()
  #   :ok
  # end

  def best_astroid(fields) do
    max = max_position(fields)

    Enum.max_by(fields, fn astroid ->
      fields |> visibles(astroid, max) |> Enum.count()
    end)
  end

  def visibles(fields, from, max) do
    fields
    |> Enum.reduce(fields, fn to, acc ->
      acc -- shadow(from, to, max)
    end)
  end

  def gcd(x, 0), do: abs(x)
  def gcd(x, y), do: gcd(y, rem(x, y))
  def divided(0, 0), do: {0, 0}
  def divided(x, y), do: divided(x, y, gcd(x, y))
  def divided(x, y, 1), do: {x, y}

  def divided(x, y, gcd) do
    x_div = div(x, gcd)
    y_div = div(y, gcd)
    divided(x_div, y_div, gcd(x_div, y_div))
  end

  def shadow({x, y} = _from, {a, b} = _to, {max_x, max_y} = _max) do
    {delta_x, delta_y} = divided(a - x, b - y)
    max_steps = max(max_x, max_y)

    # Enum.reduce_while(enumerable, acc, fun)
    for step <- 1..max_steps,
        new_x = a + step * delta_x,
        new_y = b + step * delta_y,
        new_x <= max_x and new_x >= 0,
        new_y <= max_y and new_y >= 0 do
      {new_x, new_y}
    end
  end

  def max_position(positions) do
    Enum.reduce(positions, {0, 0}, fn {x, y}, {max_x, max_y} ->
      {max(x, max_x), max(y, max_y)}
    end)
  end

  def parse_field(field) do
    field
    |> String.split()
    |> Enum.reduce({[], 0}, fn line, {acc, y} ->
      {acc ++ line_asteroids(line, y), y + 1}
    end)
    |> elem(0)
  end

  def line_asteroids(line, y) do
    line
    |> String.to_charlist()
    |> Enum.reduce({[], 0}, fn
      ?., {acc, x} -> {acc, x + 1}
      ?#, {acc, x} -> {[{x, y} | acc], x + 1}
      ?X, {acc, x} -> {acc, x + 1}
    end)
    |> elem(0)
  end

  def astroid_field_test1() do
    """
    .#..#
    .....
    #####
    ....#
    ...##
    """
  end

  def astroid_field_test2() do
    """
    ......#.#.
    #..#.#....
    ..#######.
    .#.#.###..
    .#..#.....
    ..#....#.#
    #..#....#.
    .##.#..###
    ##...#..#.
    .#....####
    """
  end

  def astroid_field_vaporize() do
    """
    .#....#####...#..
    ##...##.#####..##
    ##...#...#.#####.
    ..#.....X...###..
    ..#.#.....#....##
    """
  end

  def astroid_field_vaporize2() do
    """
    ........#........
    ........#........
    ........#........
    ........X........
    .................
    """
  end

  def astroid_field_input() do
    """
    .#......##.#..#.......#####...#..
    ...#.....##......###....#.##.....
    ..#...#....#....#............###.
    .....#......#.##......#.#..###.#.
    #.#..........##.#.#...#.##.#.#.#.
    ..#.##.#...#.......#..##.......##
    ..#....#.....#..##.#..####.#.....
    #.............#..#.........#.#...
    ........#.##..#..#..#.#.....#.#..
    .........#...#..##......###.....#
    ##.#.###..#..#.#.....#.........#.
    .#.###.##..##......#####..#..##..
    .........#.......#.#......#......
    ..#...#...#...#.#....###.#.......
    #..#.#....#...#.......#..#.#.##..
    #.....##...#.###..#..#......#..##
    ...........#...#......#..#....#..
    #.#.#......#....#..#.....##....##
    ..###...#.#.##..#...#.....#...#.#
    .......#..##.#..#.............##.
    ..###........##.#................
    ###.#..#...#......###.#........#.
    .......#....#.#.#..#..#....#..#..
    .#...#..#...#......#....#.#..#...
    #.#.........#.....#....#.#.#.....
    .#....#......##.##....#........#.
    ....#..#..#...#..##.#.#......#.#.
    ..###.##.#.....#....#.#......#...
    #.##...#............#..#.....#..#
    .#....##....##...#......#........
    ...#...##...#.......#....##.#....
    .#....#.#...#.#...##....#..##.#.#
    .#.#....##.......#.....##.##.#.##
    """
  end
end
