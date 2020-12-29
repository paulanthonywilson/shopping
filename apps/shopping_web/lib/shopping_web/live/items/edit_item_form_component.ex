defmodule ShoppingWeb.EditItemFormComponent do
  @moduledoc """
  Just allows the category to be changed.
  """
  use ShoppingWeb, :live_component

  def render(assigns) do
    ~L"""
    <form phx-change="update-item-category">
    <div class="row"> <div class="column">
    <label for="item-category-id">Category for <%= @item.name %></label>
    </div>
    </div>
    <div class="row"><div class="column">
    <select name="item-category-id">
     <%=
      options_for_select(select_otions(@categories), @item.category_id)
      %>
    </select>
    </div>
    <div class="column column-20">
    <%= link "Delete", to: "#", phx_click: "delete", phx_value_id: @item.id, class: "button delete-button",
    data: [confirm: "Are you sure you want to delete \"#{@item.name}\"?"] %>
    </div>
     </div>
    </form>

    """
  end

  defp select_otions(categories) do
    for %{emoji: emoji, category_name: name, id: id} <- categories do
      {"#{emoji} #{name}", id}
    end
  end
end
