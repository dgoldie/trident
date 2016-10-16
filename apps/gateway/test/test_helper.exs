Code.compiler_options warnings_as_errors: true
ExUnit.start()

defmodule Gateway.TestHelper do
  def set_play_mode do
    Application.put_env :gateway, :record, false
    Application.put_env :gateway, :play, true
  end

  def set_record_mode do
    Application.put_env :gateway, :record, true
    Application.put_env :gateway, :play, false
  end

  def set_play_and_record_mode do
    Application.put_env :gateway, :record, true
    Application.put_env :gateway, :play, true
  end

  def set_proxy_mode do
    Application.put_env :gateway, :record, false
    Application.put_env :gateway, :play, false
  end
end

