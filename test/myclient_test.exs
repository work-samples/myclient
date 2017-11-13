defmodule MyclientTest do
  use ExUnit.Case
  # doctest Myclient

  test "make a HTTP successful call" do
    url = "https://raw.githubusercontent.com/work-samples/myclient/master/LICENSE"
    %{body: _body,
      status_code: 200,
      request_url: ^url,
      headers: _headers} = HTTPoison.get!(url)
  end

  test "make a failed HTTP call" do
    url = "https://raw.githubusercontent.com/work-samples/myclient/master/garbage"
    %{body: _body,
      status_code: 404,
      request_url: ^url,
      headers: _headers} = HTTPoison.get!(url)
  end

  test "make :ok/:error call" do
    url = "https://raw.githubusercontent.com/work-samples/myclient/master/garbage"
    {:ok, %HTTPoison.Response{body: _body,
                              status_code: 404,
                              request_url: ^url,
                              headers: _headers}} = HTTPoison.get(url)

    url = "ppq://url.com"
    {:error, %HTTPoison.Error{reason: :nxdomain}} = HTTPoison.get(url)
  end

end
