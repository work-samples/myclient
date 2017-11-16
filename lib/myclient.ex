defmodule Myclient do


  @doc"""
  Send a GET request to the API

  ## Examples

      iex> Myclient.get("http://localhost:4849")
      {:error, :econnrefused}

      iex> Myclient.get("http://localhost:4000")
      {200, %{version: "0.1.0"}}

      iex> Myclient.get("http://localhost:4000", %{user: "andrew"})
      {200, %{version: "0.1.0", user: "andrew"}}

      iex> Myclient.get("http://localhost:4000/droids/bb10")
      {404, %{error: "unknown_resource", reason: "/droids/bb10 is not the path you are looking for"}}
  """
  def get(url, query_params \\ %{}, headers \\ []) do
    url
    |> call(query_params, headers)
    |> content_type
    |> decode
  end

  @doc"""
  Call the API service
  """
  def call(url, query_params \\ %{}, headers \\ []) do
    url
    |> clean_url
    |> HTTPoison.get(headers, params: query_params)
    |> case do
        {:ok, %{body: raw_body, status_code: code, headers: headers}} ->
          {code, raw_body, headers}
        {:error, %{reason: reason}} -> {:error, reason, []}
       end
  end

  @doc"""
  Extract the content type of the headers

  ## Examples

      iex> Myclient.content_type({:ok, "<xml />", [{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}]})
      {:ok, "<xml />", "application/xml"}

      iex> Myclient.content_type([])
      "application/json"

      iex> Myclient.content_type([{"Content-Type", "plain/text"}])
      "plain/text"

      iex> Myclient.content_type([{"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"

      iex> Myclient.content_type([{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"
  """
  def content_type({ok, body, headers}), do: {ok, body, content_type(headers)}
  def content_type([]), do: "application/json"
  def content_type([{ "Content-Type", val } | _]), do: val |> String.split(";") |> List.first
  def content_type([_ | t]), do: t |> content_type

  @doc"""
  Decode the response body

  ## Examples

      iex> Myclient.decode({:ok, "{\\\"a\\\": 1}", "application/json"})
      {:ok, %{a: 1}}

      iex> Myclient.decode({500, "", "application/json"})
      {500, ""}

      iex> Myclient.decode({:error, "{\\\"a\\\": 1}", "application/json"})
      {:error, %{a: 1}}

      iex> Myclient.decode({:ok, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> Myclient.decode({:error, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> Myclient.decode({:error, :nxdomain, "application/dontcare"})
      {:error, :nxdomain}

  """
  def decode({ok, body, _}) when is_atom(body), do: {ok, body}
  def decode({ok, "", _}), do: {ok, ""}
  def decode({ok, body, "application/json"}) do
    body
    |> Poison.decode(keys: :atoms)
    |> case do
         {:ok, parsed} -> {ok, parsed}
         _ -> {:error, body}
       end
  end
  def decode({ok, body, "application/xml"}) do
    try do
      {ok, body |> :binary.bin_to_list |> :xmerl_scan.string}
    catch
      :exit, _e -> {:error, body}
    end
  end
  def decode({ok, body, _}), do: {ok, body}


  @doc"""
  Clean the URL, if there is a port, but nothing after, then ensure there's a
  ending '/' otherwise you will encounter something like
  hackney_url.erl:204: :hackney_url.parse_netloc/2

  ## Examples

      iex> Myclient.clean_url("http://localhost")
      "http://localhost"

      iex> Myclient.clean_url("http://localhost:4000/b")
      "http://localhost:4000/b"

      iex> Myclient.clean_url("http://localhost:4000")
      "http://localhost:4000/"

  """
  def clean_url(url) do
    url
    |> String.split(":")
    |> List.last
    |> Integer.parse
    |> case do
         {_, ""} -> url <> "/"
         _ -> url
       end
  end

end
