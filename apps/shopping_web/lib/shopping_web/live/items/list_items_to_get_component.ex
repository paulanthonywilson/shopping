defmodule ShoppingWeb.ListItemsToGetComponent do
  @moduledoc """
  Items that we need to get
  """
  use ShoppingWeb, :live_component

  import ShoppingWeb.DisplayItemComponent

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <table class="to_get item_list">
      <thead>
      <th>Got</th>
      <th></th>
      <th>Need</th>
      </thead>
      <tbody>
      <%= for item <- @items do %>
        <tr class={if item.important?, do: "important"} id={"to_get_#{item.id}"}>
        <td class="item_got check">
          <%= checkbox(:get_item, :got?, value: item.got?, phx_click: "change-got", phx_value_id: item.id) %>
          <% # When an added item is at the end of the list the checkbox is not returned across the socket, without this hidden field. %>
          <%= hidden_input(:get_item, :got?, value: "") %>
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
    </table>
    """
  end
end
