defmodule Doggos.UserRouter do
  use Plug.Router

#  import Doggos.Repository
#  import Doggos.User

  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)
  
#  post "/register" do
#	{username, password} = {
#         Map.get(conn.params, "username", nil),
#         Map.get(conn.params, "password", nil)
#       }
#
#	cond do
#         is_nil(username) ->
#           conn
#           |> put_status(400)
#           |> assign(:jsonapi, %{"error" => "'username' field must be provided"})
#         is_nil(password) ->
#           conn
#           |> put_status(400)
#           |> assign(:jsonapi, %{"error" => "'password' field must be provided"})
#         true ->
#           Doggos.Repository.add_user(%Doggos.User{
#             username: username,
#             password: password
#           })
#               conn
#               |> put_resp_content_type("application/json")
#               |> send_resp(201, Poison.encode!(%{:data => %Doggos.User{
#                 username: username,
#                 password: password
#               }}))
#       end
#  end
#
  post "/login" do
	{username, password} = {
         Map.get(conn.params, "username", nil),
         Map.get(conn.params, "password", nil)
       }
	

	if username == "admin" and password == "admin" do
		{:ok, token_with_default_claims, _ } =
			Doggos.Token.generate_and_sign()
		conn
		|> put_resp_content_type("application/json")
		|> send_resp(200, Poison.encode!(%{:token => token_with_default_claims}))
	else
		send_resp(conn, 404, "Page not found!")
		end
	end
end
