defmodule ShoppingWeb.ListItemsGotComponent do
  @moduledoc """
  Items that we already have

  """
  use ShoppingWeb, :live_component

  alias ShoppingWeb.FilteredItemList

  import ShoppingWeb.DisplayItemComponent
  import ShoppingWeb.ItemGotAge

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
        <th>Last got</th>
      </thead>
      <tbody>
      <%= for item <- @items do %>
        <tr class="<%= if item.important?, do: "important" %> ">
        <td class="item_got check">
          <%= checkbox(:get_item, :got?, value: item.got?,
            phx_click: "change-got", phx_value_id: item.id) %>
        </td>
        <td class="item name"><%= display_item(@socket, item) %> </td>
        <td class="item last-got"><%= got_age(item) %></td>
         </tr>
      <% end %>
      </tbody>
    """
  end
end
