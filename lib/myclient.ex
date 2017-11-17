defmodule Myclient do

  @doc"""
  Send a GET request to the API

  ## Examples

      iex> Myclient.get("http://localhost:4000")
      {200, %{version: "0.1.0"}}

  """
  defdelegate get(url, query_params \\ %{}, headers \\ []), to: Myclient.Api

  @doc"""
  Send a POST request to the API

  ## Examples

      iex> Myclient.Api.post("http://localhost:4000", %{version: "2.0.0"})
      {201, %{version: "2.0.0"}}

  """
  defdelegate post(url, body \\ nil, headers \\ []), to: Myclient.Api

end
