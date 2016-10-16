defmodule Gateway.Data do
  @moduledoc false


  @doc ~S"""
  HTTP request/response structure used record/play them.
  ## Example
      iex> Gateway.Data.__struct__
      %Gateway.Data{request: [:url, :remote, :method, :headers, :request_body, :options],
            response: [:body, :cookies, :status_code, :headers]}
  """
  defstruct request: [:url, :remote, :method, :headers, :request_body, :options],
            response: [:body, :cookies, :status_code, :headers]
end
