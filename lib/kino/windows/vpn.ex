defmodule Kino.Windows.VPN do
  defp out_to_md(output) do
    str =
      output
      |> case do
        {:ok, message} -> 
          message
        {:error, error_code, message} ->

          "Error #{error_code}\n\n" <> message
      end


    ("- " <>
       str)
    |> String.trim("\n")
    |> String.split("\n")
    |> Enum.join("\n- ")
  end

  @doc """

  ## Examples
     iex> Kino.Windows.VPN.new("MSFT-AzVPN-Manual")
  """
  def new(vpn_name) do
    button_conect_vpn = Kino.Control.button("Connect to VPN")
    button_disconnect_vpn = Kino.Control.button("Disconnect from VPN")
    frame = Kino.Frame.new()

    Kino.listen(button_conect_vpn, fn _ ->
      Kino.Frame.render(frame, Kino.Markdown.new("### Connecting"))
      result = Windows.VPN.connect(vpn_name)
      Kino.Frame.append(frame, Kino.Markdown.new(out_to_md(result)))
    end)

    Kino.listen(button_disconnect_vpn, fn _ ->
      Kino.Frame.render(frame, Kino.Markdown.new("### Disconnecting"))
      result = Windows.VPN.disconnect(vpn_name)
      Kino.Frame.append(frame, Kino.Markdown.new(out_to_md(result)))
    end)

    button_layout = Kino.Layout.grid([button_conect_vpn, button_disconnect_vpn], columns: 2)
    Kino.Layout.grid([button_layout, frame], columns: 1)
  end
end
