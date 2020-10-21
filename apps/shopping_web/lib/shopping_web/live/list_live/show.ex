defmodule ShoppingWeb.ListLive.Show do
  use ShoppingWeb, :live_view

  alias Shopping.Lists

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    list = Lists.get_list!(id)
    {:noreply,
     socket
     |> assign(:page_title, list.name)
     |> assign(:list, list)}
  end
end
