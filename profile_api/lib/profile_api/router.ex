defmodule Profiles.Router do
  use Plug.Router
  use Timex
  alias Profiles.Profile
  import Ecto.Query

#  @skip_token_verification %{jwt_skip: true}
#  @skip_token_verification_view %{view: DogView, jwt_skip: true}
#  @auth_url Application.get_env(:profiles, :auth_url)
#  @api_port Application.get_env(:profiles, :port)
#  @db_table Application.get_env(:profiles, :redb_db)
#  @db_name Application.get_env(:profiles, :redb_db)

  #use Profiles.Auth
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
#  plug Profiles.AuthPlug
  plug(:dispatch)


  get "/get-by-name" do
    name = Map.get(conn.params, "name", nil)
    profiles =  Profiles.Repo.one(from d in Profiles.Profile, where: d."Name" == ^name)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(profiles))
  end

  get "/get-by-user" do
    userid = Map.get(conn.params, "user_id", nil)
    profiles =  Profiles.Repo.one(from d in Profiles.Profile, where: d."AccountId" == ^userid)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(profiles))
  end

  get "/get-all" do
    profiles =  Profiles.Repo.all(from d in Profiles.Profile)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(profiles))
  end

  post "/get-recommendations-by-id" do
    profile_id = Map.get(conn.body_params, "current_profile_id", nil)
    filter_ids = Map.get(conn.body_params, "filter_ids", nil)
    Logger.debug inspect(conn.body_params)


    profile = Profiles.Repo.get(Profiles.Profile, profile_id)
    Logger.debug inspect(profile)
    Logger.debug inspect(profile."ProfileType")
    Logger.debug inspect(profile."ProfileType" == "car")

    match_type =
      if profile."ProfileType" == "car" do
          "driver"
      else
          "car"
    end
    Logger.debug inspect(match_type)


    profiles =  Profiles.Repo.all(from d in Profiles.Profile, where: d."ProfileType" == ^match_type and d."ProfileId" not in ^filter_ids)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(profiles))
  end

  get "/:id" do
    case Profiles.Repo.get(Profiles.Profile, id) do
      profile ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(profile))
      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(%{"error" => "'profile' not found"}))
    end
 end

  post "/insert" do
    Logger.debug inspect(conn.body_params)

    {user_id, name, type} = {
      Map.get(conn.body_params, "user_id", nil),
      Map.get(conn.body_params, "name", nil),
      Map.get(conn.body_params, "profile_type", nil)
    }

    {user_id, ""} = Integer.parse(user_id)

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'name' field must be provided"})
      is_nil(user_id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'userid' field must be provided"})
      true ->
        case %Profile{
          AccountId: user_id,
          Name: name,
          ProfileType: type,
          Description: ""
        } |> Profiles.Repo.insert do
          {:ok, new_profile} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Poison.encode!(%{:data => new_profile}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(507, Poison.encode!(%{"error" => "An unexpected error happened"}))

        end
    end
  end

  put "/update" do
    Logger.debug inspect(conn.body_params)

    {id, name, type, description} = {
      Map.get(conn.body_params, "id", nil),
      Map.get(conn.body_params, "name", nil),
      Map.get(conn.body_params, "profile_type", nil),
      Map.get(conn.body_params, "description", nil)
    }

    {id, ""} = Integer.parse(id)

    cond do
      is_nil(name) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'name' field must be provided"})
      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'userid' field must be provided"})
      true ->
        case Profiles.Repo.get(Profiles.Profile, id)
        |> Ecto.Changeset.change(%{Name: name, Description: description, ProfileType: type})
        |> Profiles.Repo.update() do
          {:ok, new_profile} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Poison.encode!(%{:data => new_profile}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(507, Poison.encode!(%{"error" => "An unexpected error happened"}))
        end
    end
  end



end