defmodule ShoppingWeb.ListItemsToGetComponent do
  use ShoppingWeb, :live_component

  alias Shopping.Items

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <table class="to_get item_list">
      <caption>To get</caption>
      <thead>
        <th>Get</th>
        <th>Item</th>
        <th>Imp</th>
      </thead>
      <tbody>
      <%= for item <- @items do %>
        <tr id="<%= item.id%>" class="<%= if item.important?, do: "important" %> ">
        <td class="item_got check">
          <%= checkbox(:get_item, :got?, value: item.got?) %>
        </td>
        <td class="item name"><%=item.name %></td>
        <td class="item_important check" >
          <%= checkbox(:get_item, :important?,
          value: item.important?,
          phx_click: "change-importance",
          phx_value_id: item.id) %>
         </td>
         </tr>
      <% end %>
      </tbody>
    """
  end
end
