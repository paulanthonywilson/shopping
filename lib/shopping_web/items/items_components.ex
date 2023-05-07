defmodule ShoppingWeb.Items.ItemsComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes, router: ShoppingWeb.Router, endpoint: ShoppingWeb.Endpoint
  alias ShoppingWeb.{FilteredItemList, ItemGotAge}

  import ShoppingWeb.CoreComponents

  attr :to_get, :list, required: true
  attr :checklist, :map, required: true

  def to_get_table(assigns) do
    ~H"""
    <.table
      id="to_get"
      rows={@to_get}
      extra_row_class_fn={
        fn
          %{important?: true} -> "bg-violet-100"
          _ -> ""
        end
      }
    >
      <:col :let={item} label="got" extra_class="w-1">
        <.change_got item={item} />
      </:col>
      <:col
        :let={item}
        label={@checklist.name}
        extra_class="text-center text-red-900 font-bold w-full"
      >
        <.link patch={~p"/checklists/#{item.checklist_id}/items/#{item.id}"}>
          <.display_item item={item} />
        </.link>
      </:col>
      <:col :let={item} label="Need" extra_class="w-1">
        <.input
          name="importance"
          value={item.important?}
          type="checkbox"
          phx-value-id={item.id}
          phx-click="change-importance"
        />
      </:col>
    </.table>
    """
  end

  attr :got, :list, required: true
  attr :filter, :string, required: true

  @spec got_table(map) :: Phoenix.LiveView.Rendered.t()
  def got_table(%{got: items, filter: filter} = assigns) do
    filtered = FilteredItemList.filter(items, filter)
    assigns = assign(assigns, :filtered, filtered)

    ~H"""
    <.table id="got" rows={@filtered} extra_class="bg-green-100 py-1">
      <:col :let={item} label="got" extra_class="w-[1rem]">
        <.change_got item={item} />
      </:col>

      <:col :let={item} label="" extra_class="">
        <.display_item item={item} />
      </:col>
      <:col :let={item} label="Last got" extra_class="w-[5rem]">
        <.got_age item={item} />
      </:col>
    </.table>
    """
  end

  defp display_item(assigns) do
    ~H"""
    <div><%= @item.category.emoji %> <%= @item.name %></div>
    """
  end

  defp change_got(assigns) do
    ~H"""
    <.input
      name="got"
      value={@item.got?}
      type="checkbox"
      phx-value-id={@item.id}
      phx-click="change-got"
    />
    """
  end

  defp got_age(assigns) do
    %{item: item} = assigns
    assigns = assign(assigns, :age, ItemGotAge.got_age(item))

    ~H"""
    <%= @age %>
    """
  end
end
