defmodule ShoppingWeb.ListItemsToGetComponent do
  use ShoppingWeb, :live_component

  import ShoppingWeb.DisplayItemComponent

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <table class="to_get item_list">
      <thead>
      <th>Got</th>
      <th></th>
      <th>Need</th>
      </thead>
      <tbody>
      <%= for item <- @items do %>
        <tr class="<%= if item.important?, do: "important" %>">
        <td class="item_got check">
          <%= checkbox(:get_item, :got?, value: item.got?,
            phx_click: "change-got", phx_value_id: item.id) %>
        </td>
        <td class="item name"><%= display_item(@socket, item) %> </td>
        <td class="item_important check" >
          <%= checkbox(:get_item, :important?, value: item.important?,
          phx_click: "change-importance",
          phx_value_id: item.id) %>
         </td>
         </tr>
      <% end %>
      </tbody>
    """
  end
end
