defmodule Todo do
  def main(argv) do
    argv |> parse_args
  end

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
    with {:ok, content} <- Storage.get() do
      content |> Enum.each(&print_task(&1["title"], &1["done"]))
    else
      {:error, reason} -> IO.inspect(reason)
    end
  end

  defp toggle_task(index) when is_number(index) do
    with {:ok, content} <- Storage.get() do
      content
      |> Enum.with_index()
      |> Enum.map(fn
        {task, ^index} -> %{"title" => task["title"], "done" => !task["done"]}
        {task, _} -> task
      end)
      |> Storage.write()

      list_tasks()
    else
      {:error, reason} -> IO.inspect(reason)
      _ -> IO.inspect("Unknown error")
    end
  end

  defp create_task(title) do
    with {:ok, content} <- Storage.get() do
      [%{"title" => title, "done" => false} | content]
      |> Storage.write()

      list_tasks()
    else
      {:error, reason} -> IO.inspect(reason)
      _ -> IO.inspect("Unknown error")
    end
  end

  defp delete_task(index) when is_number(index) do
    with {:ok, content} <- Storage.get() do
      content
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> i != index end)
      |> Enum.map(fn {task, _} -> task end)
      |> Storage.write()

      list_tasks()
    else
      {:error, reason} -> IO.inspect(reason)
      _ -> IO.inspect("Unknown error")
    end
  end

  defp print_task(title, false), do: IO.puts("- [ ] #{title}")

  defp print_task(title, true), do: IO.puts("- [x] #{title}")
end
