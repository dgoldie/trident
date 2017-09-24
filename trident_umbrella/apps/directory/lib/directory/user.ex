defmodule Directory.User do
  alias Directory.User
  @enforce_keys [:email, :first_name, :last_name, :encrypted_password]
  defstruct [:email, :first_name, :last_name, :encrypted_password]


  def create(attrs = %{}) do
    %User{ email:              Map.fetch!(attrs, :email),
           first_name:         Map.fetch!(attrs, :first_name),
           last_name:          Map.fetch!(attrs, :last_name),
           encrypted_password: hashed_password(attrs[:password])
          }
  end

  def hashed_password(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end

  def authenticate(user = %User{}, password) do
    Comeonin.Bcrypt.checkpw(password, user.encrypted_password)
  end
end
