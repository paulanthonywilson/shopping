defmodule ShoppingWeb.ListItemsGotComponent do
  use ShoppingWeb, :live_component

  def render(assigns) do
    ~L"""
    <table class="got item_list">
      <caption>Got</caption>
      <thead>
        <th>Got</th>
        <th>Item</th>
      </thead>
      <tbody>
      <%= for item <- @items do %>
        <tr id="<%= item.id%>" class="<%= if item.important?, do: "important" %> ">
        <td class="item_got check">
          <%= checkbox(:get_item, :got?, value: item.got?,
            phx_click: "change-got", phx_value_id: item.id) %>
        </td>
        <td class="item name"><%=item.name %></td>
         </tr>
      <% end %>
      </tbody>
    """
  end
end
