defmodule BeerDispenserWeb.FormHelpers do
  use Phoenix.HTML

  def label_tag(form, field, info \\ "") do
    name =
      field
      |> Atom.to_string()
      |> String.split("_")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join(" ")

    label form, field do
      ~E"""
      <%= name %> <%= content_tag :span, info, class: "info-span" %>
      """
    end
  end
end
