defmodule ShoppingWeb.EditItemFormComponent do
  use ShoppingWeb, :live_component

  def render(assigns) do
    ~L"""

    <%= @return_to %>
    <form phx-change="update-item-category">
    <label for="item-category-id">Category for <%= @item.name %></label>
    <select name="item-category-id">
     <%=
      options_for_select(select_otions(@categories), @item.category_id)
      %>
    </select>
    </form>

    """
  end

  defp select_otions(categories) do
    for %{emoji: emoji, category_name: name, id: id} <- categories do
      {"#{emoji} #{name}", id}
    end
  end
end
