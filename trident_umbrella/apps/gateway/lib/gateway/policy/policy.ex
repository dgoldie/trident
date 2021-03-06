defmodule Gateway.Policy do
  alias Plug.Conn
  require IEx




  def protected_route?(conn) do
    IO.puts "protected_route?"
    proxy = target_proxy(conn)
    route = conn.request_path
    IO.puts "...route = #{inspect route}"
    # IO.puts "****** proxy allow = #{inspect proxy[:allow]}"
    allow? = proxy[:allow] ++ asset_matchers()
    |> Enum.filter( fn(path) ->
      m2 = Fuzzyurl.mask(path: path)
      Fuzzyurl.matches?(m2, route)
    end)
    |> Enum.any?

    IO.puts "**** this route matches allow list = #{allow?}"
    not allow?
  end


  @spec proxies() :: []
  defp proxies,
    do: Application.get_env :gateway, :proxies, nil

  # defp find_proxy(conn) do
  #   IO.puts "find proxy"
  #   port = conn.port
  #   IO.puts "port = #{port}"
  #   Enum.find(proxies(), fn(x) -> match?(%{port: port}, x) end)
  # end

  # different implementation of find_proxy
  #
  defp target_proxy(conn) do
    proxies()
    |> Enum.reduce([], fn proxy, acc ->
      if proxy.port == conn.port, do: [proxy | acc], else: acc
    end)
    |> Enum.at(0)
  end

  defp asset_matchers do
    ~w(.css .js .jpg .png .gif .bmp .ico)
    |> Enum.map(fn (x) -> "**" <> x end)
  end

#   def get_policy(route, policy) do
#     IO.puts "get policy - route = #{route}"
#     routes_with_regexes(policy.routes)
#     |> find_policy(route)
#   end

#   defp routes_with_regexes(routes) do
#     routes
#     |> Enum.map( fn({k,v}) ->
#         IO.puts "k = #{k}, v = #{v}"

#         k = to_string(k)
#         if String.ends_with?(k, "/") do
#           k = k <> "$"
#         end

#         [Regex.compile!(k), v]

#        end)
#   end

#   defp find_policy(regexes_with_policies, route) do
#     IO.puts "regx w pol - #{inspect regexes_with_policies}"
#     result = regexes_with_policies
#     |> Enum.find( fn([r,p]) ->
#         IO.puts("r, p = #{p}")
#         Regex.match?(r, route)
#        end)
#     IO.puts "result find policy = #{inspect result}"
#     case result do
#       nil -> nil
#       other -> Enum.at(other, 1)
#     end
#   end
end
