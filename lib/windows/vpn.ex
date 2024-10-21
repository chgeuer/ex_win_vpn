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
end
