defmodule Docs.Router do
  use Docs.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Docs.Plugs.AssignCurrentUser
  end

  pipeline :require_authenticated do
    plug Docs.Plugs.Authenticate
  end


  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Docs do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", Docs do
    pipe_through [:browser, :require_authenticated]

    resources "/documents", DocumentController, except: [:new, :edit, :update] do
      resources "/invitations", InvitationController, only: [:index, :create]

      get "/invitations/accept", InvitationController, :accept
    end
  end

  scope "/auth", Docs do
    pipe_through :browser

    get "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end
end
