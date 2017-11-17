defmodule Myclient.Client do

  @doc"""
  Extract the current version

  ## Examples

      iex> Myclient.Client.current_version()
      "0.1.0"

  """
  def current_version() do
    "http://localhost:4000"
    |> Myclient.Api.get
    |> (fn {200, %{version: version}} -> version end).()
  end

  @doc"""
  Set the next version

  ## Examples

      iex> Myclient.Client.next_version("1.2.3")
      "1.2.3"

  """
  def next_version(version) do
    "http://localhost:4000"
    |> Myclient.Api.post(%{version: version})
    |> (fn {201, %{version: version}} -> version end).()
  end

end