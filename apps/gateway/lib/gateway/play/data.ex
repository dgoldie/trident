defmodule Gateway.Play.Data do
  @moduledoc """
  Gateway.Play.Data is structure for play response mode.
  The structure gets data via Gateway.Play.Response.play_responses.
  """

  alias Gateway.Play.Response, as: GatewayResponse
  alias Gateway.Agent, as: ProxyAgent

  @responses :play_responses

  @doc ~S"""
  Return `responses` stored in Agent.
  ## Example
      iex> Gateway.Play.Data.responses[:"get_8080/request/path"]
      %{"request" => %{"method" => "GET",
           "path" => "/request/path", "port" => 8080},
         "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
           "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
             "Server" => "GFE/2.0"}, "status_code" => 200}}
      iex> Gateway.Play.Data.responses[:"get_8080\\A/request.*neko\\z"]
      %{"request" => %{"method" => "GET",
           "path_pattern" => "\\A/request.*neko\\z", "port" => 8080},
         "response" => %{"body_file" => "test/data/__files/example.json", "cookies" => %{},
           "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
             "Server" => "GFE/2.0"}, "status_code" => 200}}
      iex> Gateway.Play.Data.responses[:"post_8081/request/path"]
      %{"request" => %{"method" => "POST",
           "path" => "/request/path", "port" => 8081},
         "response" => %{"body" => "<html>hello world 3</html>", "cookies" => %{},
           "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
             "Server" => "GFE/2.0"}, "status_code" => 201}}
  """
  @spec responses() :: binary
  def responses(), do: response ProxyAgent.get(@responses)
  defp response(nil) do
    ProxyAgent.put @responses, GatewayResponse.play_responses
    responses()
  end
  defp response(val), do: val

  @doc """
  Put nil value to stored :play_responses key
  """
  @spec clear_responses() :: :ok
  def clear_responses, do: ProxyAgent.put @responses, nil
end
