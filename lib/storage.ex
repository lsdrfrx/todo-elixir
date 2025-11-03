defmodule Storage do
  def get(path \\ "tasks.json") do
    with {:ok, content} <- File.read(path),
         {:ok, decoded} <- JSON.decode(content) do
      {:ok, decoded}
    else
      {:error} -> {:error, "Failed to read file #{path}"}
    end
  end

  def write(content, path \\ "tasks.json") do
    with encoded <- JSON.encode_to_iodata!(content),
         :ok <- File.write(path, encoded) do
      :ok
    else
      _ -> {:error, "Failed to save file"}
    end
  end
end
