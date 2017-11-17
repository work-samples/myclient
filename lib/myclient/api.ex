defmodule Myclient.Api do

  @doc"""
  Send a GET request to the API

  ## Examples

      iex> Myclient.Api.get("http://localhost:4849")
      {:error, :econnrefused}

      iex> Myclient.Api.get("http://localhost:4000")
      {200, %{version: "0.1.0"}}

      iex> Myclient.Api.get("http://localhost:4000", %{user: "andrew"})
      {200, %{version: "0.1.0", user: "andrew"}}

      iex> Myclient.Api.get("http://localhost:4000/droids/bb10")
      {404, %{error: "unknown_resource", reason: "/droids/bb10 is not the path you are looking for"}}
  """
  def get(url, query_params \\ %{}, headers \\ []) do
    call(url, :get, "", query_params, headers)
  end

  @doc"""
  Send a POST request to the API

  ## Examples

      iex> Myclient.Api.post("http://localhost:4000", %{version: "2.0.0"})
      {201, %{version: "2.0.0"}}

  """
  def post(url, body \\ nil, headers \\ []) do
    call(url, :post, body, %{}, headers)
  end

  @doc"""
  Call the API service

  ## Examples

      iex> Myclient.Api.call("http://localhost:4000", :post, %{version: "2.0.0"}, %{user: "james"})
      {201, %{version: "2.0.0", user: "james"}}

  """
  def call(url, method, body \\ "", query_params \\ %{}, headers \\ []) do
    HTTPoison.request(
      method,
      url |> clean_url,
      body |> encode(content_type(headers)),
      headers |> clean_headers,
      params: query_params
    )
    |> case do
        {:ok, %{body: raw_body, status_code: code, headers: headers}} ->
          {code, raw_body, headers}
        {:error, %{reason: reason}} -> {:error, reason, []}
       end
    |> content_type
    |> decode
  end

  @doc"""
  Extract the content type of the headers

  ## Examples

      iex> Myclient.Api.content_type({:ok, "<xml />", [{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}]})
      {:ok, "<xml />", "application/xml"}

      iex> Myclient.Api.content_type([])
      "application/json"

      iex> Myclient.Api.content_type([{"Content-Type", "plain/text"}])
      "plain/text"

      iex> Myclient.Api.content_type([{"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"

      iex> Myclient.Api.content_type([{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"
  """
  def content_type({ok, body, headers}), do: {ok, body, content_type(headers)}
  def content_type([]), do: "application/json"
  def content_type([{ "Content-Type", val } | _]), do: val |> String.split(";") |> List.first
  def content_type([_ | t]), do: t |> content_type

  @doc"""
  Encode the body to pass along to the server

  ## Examples

      iex> Myclient.Api.encode(%{a: 1}, "application/json")
      "{\\"a\\":1}"

      iex> Myclient.Api.encode("<xml/>", "application/xml")
      "<xml/>"

      iex> Myclient.Api.encode(%{a: "o ne"}, "application/x-www-form-urlencoded")
      "a=o+ne"

      iex> Myclient.Api.encode("goop", "application/mytsuff")
      "goop"

  """
  def encode(data, "application/json"), do: Poison.encode!(data)
  def encode(data, "application/xml"), do: data
  def encode(data, "application/x-www-form-urlencoded"), do: URI.encode_query(data)
  def encode(data, _), do: data

  @doc"""
  Decode the response body

  ## Examples

      iex> Myclient.Api.decode({:ok, "{\\\"a\\\": 1}", "application/json"})
      {:ok, %{a: 1}}

      iex> Myclient.Api.decode({500, "", "application/json"})
      {500, ""}

      iex> Myclient.Api.decode({:error, "{\\\"a\\\": 1}", "application/json"})
      {:error, %{a: 1}}

      iex> Myclient.Api.decode({:ok, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> Myclient.Api.decode({:error, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> Myclient.Api.decode({:error, :nxdomain, "application/dontcare"})
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

      iex> Myclient.Api.clean_url("http://localhost")
      "http://localhost"

      iex> Myclient.Api.clean_url("http://localhost:4000/b")
      "http://localhost:4000/b"

      iex> Myclient.Api.clean_url("http://localhost:4000")
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

  @doc"""
  Clean the URL, if there is a port, but nothing after, then ensure there's a
  ending '/' otherwise you will encounter something like
  hackney_url.erl:204: :hackney_url.parse_netloc/2

  ## Examples

      iex> Myclient.Api.clean_headers([])
      [{"Content-Type", "application/json; charset=utf-8"}]

      iex> Myclient.Api.clean_headers([{"apples", "delicious"}])
      [{"apples", "delicious"}]

  """
  def clean_headers([]), do: [{"Content-Type", "application/json; charset=utf-8"}]
  def clean_headers(h), do: h

end
