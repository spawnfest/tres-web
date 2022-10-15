defmodule InspectorDayaWeb.PageLive do
  @moduledoc false
  use InspectorDayaWeb, :live_view
  alias Discovery.Bridge.BridgeUtils
  alias Discovery.Deploy.DeployUtils
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       query: "",
       results: %{},
       apps: [],
       selected_app: nil,
       create_modal_display: "none",
       deploy_modal_display: "none",
       create_app_warning: "none",
       deploy_app_warning: "none",
       modal_input?: true,
       selected_app_details: %{}
     )}
  end

  @impl true
  def handle_event("create-app", %{"app-name" => app_name} = _params, socket) do
    # socket =
    #   if socket.assigns.modal_input? do
    #     case app_name |> create_app() do
    #       {:ok, :app_inserted} ->
    #         new_app = %{
    #           app_name: app_name,
    #           deployments: 0
    #         }

    #         socket
    #         |> assign(
    #           modal_input?: false,
    #           apps: [new_app | socket.assigns.apps],
    #           create_modal_display: "none"
    #         )

    #       {:error, :app_present} ->
    #         socket |> assign(create_app_warning: "block")
    #     end
    #   else
    #     socket
    #   end

    {:noreply, socket}
  end

  @impl true
  def handle_event("create-deployment", %{"app-image" => app_image} = _params, socket) do
    # if socket.assigns.modal_input? do
    #   %DeployUtils{
    #     app_name: socket.assigns.selected_app,
    #     app_image: app_image
    #   }
    #   |> create_deployment()
    # end

    # socket =
    #   socket
    #   |> assign(modal_input?: false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select-app", %{"app" => app_name} = _params, socket) do
    # selected_app_details =
    #   app_name
    #   |> BridgeUtils.get_deployment_data()

    # socket =
    #   socket
    #   |> assign(selected_app: app_name, selected_app_details: selected_app_details)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show-create-modal", _params, socket) do
    # display =
    #   case socket.assigns.create_modal_display do
    #     "none" -> "block"
    #     "block" -> "none"
    #     _ -> "none"
    #   end

    # socket =
    #   socket
    #   |> assign(create_modal_display: display, modal_input?: true, create_app_warning: "none")

    {:noreply, socket}
  end

  @impl true
  def handle_event("show-deploy-modal", _params, socket) do
    # display =
    #   case socket.assigns.deploy_modal_display do
    #     "none" -> "block"
    #     "block" -> "none"
    #     _ -> "none"
    #   end

    # socket =
    #   socket
    #   |> assign(deploy_modal_display: display, modal_input?: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide-modal", _params, socket) do
    # socket =
    #   socket
    #   |> assign(
    #     create_modal_display: "none",
    #     deploy_modal_display: "none",
    #     deploy_app_warning: "none",
    #     modal_input?: true
    #   )

    {:noreply, socket}
  end

  @impl true
  def handle_event("back", _params, socket) do
    # socket =
    #   socket
    #   |> assign(selected_app: nil)

    {:noreply, socket}
  end

end
