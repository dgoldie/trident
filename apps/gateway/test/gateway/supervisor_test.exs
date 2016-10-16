defmodule Gateway.SupervisorTest do
  use ExUnit.Case, async: true

  test "check subversion tree" do
    pid = Process.whereis Gateway.Supervisor
    assert pid != nil

    children = Supervisor.which_children Gateway.Supervisor
    assert Enum.count(children) == 3

    {id, _, _, modules} = hd(children)
    assert id == :"Gateway.Handle8080"
    assert modules == [Gateway.Handle]

    {id, _, _, modules} = List.last(children)
    assert id == Gateway.Agent
    assert modules == [Gateway.Agent]
  end
end
