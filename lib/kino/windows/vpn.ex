defmodule Kino.Windows.VPN do
  @doc """
  Creates a VPN connection toggle widget.
  The toggle will reflect the VPN connection status and allow toggling.

  ## Parameters

  * `vpn_name` - The name of the VPN connection to manage
  * `refresh_interval` - How often to refresh the connection state in milliseconds (default: 5000)

  ## Examples
     iex> Kino.Windows.VPN.new("MSFT-AzVPN-Manual")
     iex> Kino.Windows.VPN.new("My-Corporate-VPN", 10000)
  """
  def new(vpn_name, refresh_interval \\ 5000) do
    # Create a frame to hold our dynamic UI components
    frame = Kino.Frame.new()

    # Initial rendering of toggle control
    render_toggle_control(frame, vpn_name)

    # Start background task to monitor VPN status and update UI
    Task.async(fn ->
      monitor_vpn_connection(frame, vpn_name, refresh_interval)
    end)

    # Return the frame
    frame
  end

  # Render the toggle control based on current VPN status
  defp render_toggle_control(frame, vpn_name) do
    # Get current VPN connection state
    is_connected = Windows.VPN.connected_to(vpn_name)

    # Create button with appropriate label based on current state
    button_label = if is_connected, do: "Disconnect from VPN", else: "Connect to VPN"
    button = Kino.Control.button(button_label)

    # Create status text
    status_text = if is_connected,
      do: "✅ Connected to #{vpn_name}",
      else: "❌ Disconnected from #{vpn_name}"

    # Create a small text component for the status
    status = Kino.Text.new(status_text)

    # Place components in the frame
    Kino.Frame.render(frame, Kino.Layout.grid([status, button], columns: 1))

    # Set up listener for the button
    Kino.listen(button, fn _ ->
      # Execute the opposite action of current state
      _result = if is_connected do
        Windows.VPN.disconnect(vpn_name)
      else
        Windows.VPN.connect(vpn_name)
      end

      # Small delay to allow the operation to complete
      Process.sleep(500)

      # Re-render the control to reflect the new state
      render_toggle_control(frame, vpn_name)
    end)
  end

  # Periodically check VPN connection and update UI if needed
  defp monitor_vpn_connection(frame, vpn_name, interval) do
    # Wait for the specified interval
    Process.sleep(interval)

    # Re-render the control to reflect current state
    render_toggle_control(frame, vpn_name)

    # Continue monitoring
    monitor_vpn_connection(frame, vpn_name, interval)
  end
end
