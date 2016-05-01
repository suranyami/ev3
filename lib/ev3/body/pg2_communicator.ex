defmodule Ev3.PG2Communicator do
	@moduledoc "Communicating with other robots via pg2"

	@behaviour Ev3.Communicating
	use GenServer
	alias Ev3.Percept
	alias Ev3.CNS
	require Logger

	@name __MODULE__

	### API

	@doc "Star the communication server"
	def start_link() do
		Logger.info("Starting #{@name}")
		GenServer.start_link(@name, [], [name: @name])
	end

	@doc "Communicate a percept to the team"
	def communicate(device, info, team) do
		GenServer.cast(@name, {:communicate, device, info, team})
	end


	### CALLBACK

	def init([]) do
		group = Application.get_env(:ev3, :group)
		:pg2.start()
		:pg2.create(group)
		:pg2.join(group, self())
		{:ok, %{group: group}}
	end

	def handle_cast({:communicate, device, info, team}, state =  %{group: group}) do
		:pg2.get_members(group)
		|> Enum.each(&(GenServer.cast(&1, {:communication, Node.self(), info, team, device.props.ttl})))
		Logger.info("COMMUNICATOR communicated #{inspect info} to team #{team}")
		{:noreply, state}
	end

	def handle_cast({:communication, source, info, team, ttl}, state) do # ttl for what's communicated
		Logger.info("COMMUNICATOR heard #{inspect info} for team #{team} from #{inspect source}")
		percept = Percept.new(about: :heard, value: %{source: source, team: team, info: info})
		CNS.notify_perceived(%{percept |
														 ttl: ttl,
														 source: @name})
		{:noreply, state}
		end

end
