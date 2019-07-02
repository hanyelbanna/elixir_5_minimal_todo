defmodule MinimalTodo do
  def start do
    input =
      IO.gets("Name of the .csv to load: ")
      |> String.trim()

    read(filename)
    |> parse
    |> get_command

    # (read todos, add todos, delete todos, load file, save files)
  end

  def get_command(data) do
    prompt = """
    Type the first letter of the command you want to run
    R)ead Todos    A)dd a Todo    D)elete a Todo    L)oad a .csv    S)ave a .csv
    """

    command =
      IO.gets(prompt)
      |> String.trim()
      |> String.downcase()

    case command do
      "r" -> show_todos(data)
      "d" -> delete_todo(data)
      "q" -> "Goodbye!"
      _ -> get_command(data)
    end
  end

  def delete_todo(data) do
    todo = IO.gets("Which todo would you like to delete?\n") |> String.trim()

    if Map.has_key?(data, todo) do
      IO.puts("ok.")
      new_map = Map.drop(data, [todo])
      IO.puts(~s("#{todo}" has been deleted.))
      get_command(new_map)
    else
      IO.puts(~s(There is no Todo named "#{todo}"!))
      show_todos(data, false)
      delete_todo(data)
    end
  end

  def read(filename) do
    case File.read(filename) do
      {:ok, body} ->
        body

      {:error, reason} ->
        IO.puts(~s(Could not open file "#{filename}"\n.))
        # functions start with : comes from erlang language
        IO.puts(~s("#{:file.format_error(reason)}"\n))
        start()
    end
  end

  def parse(body) do
    [header | lines] = String.split(body, ~r{(\r\n|\r|\n)})
    # tl function return the tail of list and hd function return the head of list
    titles = tl(String.split(header, ","))
    parse_lines(lines, titles)
  end

  """
  1. Enum.reduce:
  iex> Enum.reduce([1, 2, 3], 0, fn(x, acc) -> x + acc end)
  accumulator acc takes 0 which is the second argument as initial value.
  x = first element in the list which is 1 and do the function on it.
  The result returned by the function is used as the accumulator for the next iteration.
  The function returns the last accumulator.

  2. Enum.zip function compine 2 lists of smae length in one list with tubles
  -> first item from first list with first item from second list in one tuble in the new list and so on
  """

  def parse_lines(lines, titles) do
    Enum.reduce(lines, %{}, fn line, built ->
      [name | fields] = String.split(line, ",")

      if Enum.count(fields) == Enum.count(titles) do
        # Enum.into convert tubles list to key: value and put in into a map
        line_data = Enum.zip(titles, fields) |> Enum.into(%{})
        # merge 2 maps
        Map.merge(built, %{name => line_data})
      else
        built
      end
    end)
  end

  # default for next_command? is true
  def show_todos(data, next_command? \\ true) do
    # return list of keys
    items = Map.keys(data)
    IO.puts("You have the following Todos:\n")
    Enum.each(items, fn item -> IO.puts(item) end)
    IO.puts("\n")

    if next_command? do
      get_command(data)
    end
  end
end
