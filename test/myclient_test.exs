defmodule MyclientTest do
  use ExUnit.Case
  doctest Myclient

  test "make a HTTP successful call" do
    url = "https://api.github.com"
    %{body: _body,
      status_code: 200,
      request_url: ^url,
      headers: _headers} = HTTPoison.get!(url)
  end

  test "make a failed HTTP call" do
    url = "https://api.github.com/garbage"
    %{body: _body,
      status_code: 404,
      request_url: ^url,
      headers: _headers} = HTTPoison.get!(url)
  end

  test "make :ok/:error call" do
    url = "https://api.github.com/garbage"
    {:ok, %HTTPoison.Response{body: _body,
                              status_code: 404,
                              request_url: ^url,
                              headers: _headers}} = HTTPoison.get(url)

    url = "ppq://url.com"
    {:error, %HTTPoison.Error{reason: :nxdomain}} = HTTPoison.get(url)
  end

  test "get" do
    {200, _body} = Myclient.get("https://api.github.com")
    {404, _body} = Myclient.get("https://api.github.com/garbage")
    {:error, _reason} = Myclient.get("ppq://url.com")
  end


  test "test parse JSON" do
    {:ok, %{a: 1}} = Poison.decode("{\"a\": 1}", keys: :atoms)
    {:error, {:invalid, "g", 1}} = Poison.decode("{goop}", keys: :atoms)
  end

end
