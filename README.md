# Trident

A simple Single Sign On application

defmodule Gateway.PolicyPlug do
  import Plug.Conn
  alias Gateway.Policy

  # def init(options) do
  #   # initialize options

  #   options
  # end

  def add_policy(conn, _opts) do
    IO.inspect "gateway requests"
    IO.inspect conn
    # subject = conn.params["subject_id"]
    Policy.process(conn)
    assign(conn, :policy, :pass)
  end
end

defmodule Gateway.Policy do

  def start_policy_db do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
  end

  def process(conn) do

  end

end

Configurations
GATEWAY host = xyz

admin : localhost:4000

map hosts/port
%{
"localhost:8088" : %{name: railsapp, host: localhost:3000}
"localhost:8089" : %{name: nodeapp, host: localhost:5000}
}

hosts = 

policy store (structure ?) storage?
railsapp: [
["/bar/*" , :pass_through]
["/foo/*" -> :protected]
]
Enum.find
Regex.compile!(n)

https://github.com/dgoldie/trident



