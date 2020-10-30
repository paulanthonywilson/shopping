defmodule ShoppingWeb.ListItemsGotComponent do
  use ShoppingWeb, :live_component

  alias ShoppingWeb.FilteredItemList

  def update(%{filter: filter, items: items}, socket) do
    filtered_items = FilteredItemList.filter(items, filter)
    {:ok, assign(socket, items: filtered_items)}
  end

  def render(assigns) do
    ~L"""
    <table class="got item_list">
      <thead>
        <th>Got</th>
        <th>Item</th>
        <th></th>
      </thead>
      <tbody>
      <%= for item <- @items do %>
        <tr class="<%= if item.important?, do: "important" %> ">
        <td class="item_got check">
          <%= checkbox(:get_item, :got?, value: item.got?,
            phx_click: "change-got", phx_value_id: item.id) %>
        </td>
        <td class="item name"><a href="#" phx-click="edit-item"><%= item.category.emoji %> <%=item.name %></a></td>
        <td class="delete">
          <%= link "Del", to: "#", phx_click: "delete", phx_value_id: item.id, data: [confirm: "Are you sure?"] %>
        </td>
         </tr>
      <% end %>
      </tbody>
    """
  end
end
