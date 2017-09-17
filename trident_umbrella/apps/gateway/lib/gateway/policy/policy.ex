defmodule Gateway.Policy do


  def authenticate?(proxy, route) do
    IO.puts "get -- policy"
    IO.inspect proxy[:auth]
    IO.puts "route = #{inspect route}"

    proxy[:auth]
    |> Enum.filter( fn(path) ->
      m2 = Fuzzyurl.mask(path: path)
      Fuzzyurl.matches?(m2, route)
    end)
    |> Enum.any?
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
