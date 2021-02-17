defmodule AssistABot.ScheduleDetail do
  @tasks [
    {"40 21 * * 1-5", "chu_texter", 1, {Tasks.ChuTexter, :send_message, []}}
  ]

  def schedule_items do
    @tasks
      |> Enum.each(&schedule_item/1)
  end

  def schedule_item({cron, name, max_run, action}) do
    Taskerville.schedule(cron, name, max_run, action)
  end
end
