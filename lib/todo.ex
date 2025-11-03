defmodule Todo do
  def main(argv) do
    argv |> parse_args
  end

  defp bind({:ok, value}, func), do: func.(value)
  defp bind({:error, reason}, _), do: {:error, reason}

  defp map({:ok, value}, func), do: {:ok, func.(value)}
  defp map({:error, reason}, _), do: {:error, reason}

  defp handle_error({:error, reason}), do: IO.puts(reason)
  defp handle_error(_), do: :ok

  defp parse_args(["list"]), do: list_tasks()

  defp parse_args(["toggle", index]),
    do:
      index
      |> String.to_integer()
      |> (fn x -> x - 1 end).()
      |> toggle_task()

  defp parse_args(["delete", index]),
    do:
      index
      |> String.to_integer()
      |> (fn x -> x - 1 end).()
      |> delete_task()

  defp parse_args(["create", title]), do: create_task(title)

  defp parse_args(_) do
    IO.puts("HELP MESSAGE")
  end

  defp list_tasks() do
    Storage.get()
    |> bind(fn content -> Enum.each(content, &print_task(&1["title"], &1["done"])) end)
    |> handle_error()
  end

  defp toggle_task(index) when is_number(index) do
    Storage.get()
    |> map(fn content ->
      content
      |> Enum.with_index()
      |> Enum.map(fn
        {task, ^index} -> %{"title" => task["title"], "done" => !task["done"]}
        {task, _} -> task
      end)
    end)
    |> map(&Storage.write/1)
    |> bind(fn _ -> list_tasks() end)
    |> handle_error()
  end

  defp create_task(title) do
    Storage.get()
    |> map(fn content -> [%{"title" => title, "done" => false} | content] end)
    |> map(&Storage.write/1)
    |> bind(fn _ -> list_tasks() end)
    |> handle_error()
  end

  defp delete_task(index) when is_number(index) do
    Storage.get()
    |> map(fn content ->
      content
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> i != index end)
      |> Enum.map(fn {task, _} -> task end)
    end)
    |> map(&Storage.write/1)
    |> bind(fn _ -> list_tasks() end)
    |> handle_error()
  end

  defp print_task(title, false), do: IO.puts("- [ ] #{title}")

  defp print_task(title, true), do: IO.puts("- [x] #{title}")
end
