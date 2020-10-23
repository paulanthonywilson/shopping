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
        <tr id="<%= item.id%>" class="<%= if item.important?, do: "important" %> ">
        <td class="item_got check">
          <%= checkbox(:get_item, :got?, value: item.got?,
            phx_click: "change-got", phx_value_id: item.id) %>
        </td>
        <td class="item name"><%=item.name %></td>
        <td class="item name"><button>Del</button></td>
         </tr>
      <% end %>
      </tbody>
    """
  end
end
