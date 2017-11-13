defmodule Myclient do

  def get(url, headers \\ []) do
    url
    |> HTTPoison.get(headers)
    |> case do
        {:ok, %{body: raw_body, status_code: code}} -> {code, raw_body}
        {:error, %{reason: reason}} -> {:error, reason}
       end
    |> (fn {ok, body} ->
          body
          |> Poison.decode(keys: :atoms)
          |> case do
               {:ok, parsed} -> {ok, parsed}
               _ -> {:error, body}
             end
        end).()
  end

end
