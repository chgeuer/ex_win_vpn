defmodule Kino.Windows.VPN do
  @doc """
  Creates a VPN connection widget with a checkbox.
  The checkbox reflects the VPN connection status and allows toggling.

  ## Parameters

  * `vpn_name` - The name of the VPN connection to manage
  * `refresh_interval` - How often to refresh the connection state in milliseconds (default: 5000)

  ## Examples
     iex> Kino.Windows.VPN.new("MSFT-AzVPN-Manual", 1_000)
  """
  def new(vpn_name, refresh_interval \\ 5000) do
    # Create a frame to hold our dynamic checkbox
    frame = Kino.Frame.new()

    # Initial rendering of checkbox
    render_checkbox(frame, vpn_name, nil)

    # Start background task to monitor VPN status and update UI
    Task.async(fn ->
      Process.sleep(refresh_interval)
      monitor_vpn_connection(frame, vpn_name, refresh_interval)
    end)

    # Return the frame
    frame
  end

  # Render the checkbox control based on current VPN status
  defp render_checkbox(frame, vpn_name, _last_state) do
    # Get current VPN connection state
    is_connected = Windows.VPN.connected_to(vpn_name)

    # Choose label based on connection state
    label = if is_connected do
      "Connected to #{vpn_name} (click to disconnect)"
    else
      "Disconnected from #{vpn_name} (click to connect)"
    end

    # Create a new checkbox with the current state
    checkbox = Kino.Input.checkbox(label, default: is_connected)

    # Render the checkbox in the frame
    Kino.Frame.render(frame, checkbox)

    # Set up listener for the checkbox
    Kino.listen(checkbox, fn %{value: requested_state} ->
      # Execute the requested action based on checkbox's current value
      if requested_state do
        Windows.VPN.connect(vpn_name)
      else
        Windows.VPN.disconnect(vpn_name)
      end

      # Small delay to allow the operation to complete
      Process.sleep(500)

      # Re-render the checkbox to reflect the new state
      render_checkbox(frame, vpn_name, is_connected)
    end)
  end

  # Periodically check VPN connection and update UI if needed
  defp monitor_vpn_connection(frame, vpn_name, interval) do
    # Re-render the checkbox to reflect current state
    render_checkbox(frame, vpn_name, nil)

    # Wait for the specified interval before checking again
    Process.sleep(interval)

    # Continue monitoring
    monitor_vpn_connection(frame, vpn_name, interval)
  end
end
