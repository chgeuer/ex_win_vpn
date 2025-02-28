defmodule Windows.VPN do
  def connect(vpn_name) do
    System.cmd("rasdial.exe", [vpn_name], stderr_to_stdout: true)
    |> case do
      {output, 0} ->
        {:ok, output}
      {output, error_code} ->
        {:error, error_code, output}
    end
  end

  def disconnect(vpn_name) do
    System.cmd("rasdial.exe", [vpn_name, "/DISCONNECT"], stderr_to_stdout: true)
    |> case do
      {output, 0} ->
        {:ok, output}
      {output, error_code} ->
        {:error, error_code, output}
    end
  end


  @no_connections "No connections"
  @connected "Connected to"
  @success "Command completed successfully."
  @doc """
  Checks current VPN connections using rasdial.exe and returns a tuple indicating status.
  
  Returns:
  - {:connected, [connection_names]} - when VPN connections are active
  - {:disconnected} - when no VPN connections are active
  """
  def list_connections do
    with {response, 0} <- System.cmd("rasdial.exe", [], stderr_to_stdout: true),
      lines <- response |> String.split("\n", trim: true) do
      lines
      |> case do
        [ @no_connections, @success] ->
          {:disconnected}
          
        [@connected | rest_with_command] ->
          {connection_names, [@success]} = Enum.split(rest_with_command, -1)
          {:connected, connection_names}
          
        _ ->
          {:error, "rasdial.exe returned unknown response: #{response}"}
      end
    end 
  end
end
