defmodule TagIp.Notification do
  @topic "dashboard"

  def subscribe do
    Phoenix.PubSub.subscribe(TagIp.PubSub, @topic)
  end

  def broadcast(event) do
    Phoenix.PubSub.broadcast(TagIp.PubSub, @topic, event)
  end
end
