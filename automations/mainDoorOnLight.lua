--[[ 
	при открытии входной двери, 
	СМК state:contact переходит в false (разомкнут или open)
	0x00158D00039272A5(0xACF8)
	Нужно включить реле, к которому подключено освещение прихожей
	0xA4C138D8A539DB0F(0x4F61)
	и запустить таймер, по окончании которого, выключить реле
	timerMainDoor
	для вызова: в SB СМК входной двери прописать mainDoorOnLight.lua,0xA4C138D8A539DB0F:state:timer(s)
	]]
-- получить состояние СМК
local state = Event.State.Value
local arr = {}
-- разбираю аргументы 
arr = explode(":", Event.Param)
-- присваиваю полученные значения переменным
local deviceAddr = arr[1]
local deviceState = arr[2]
local timer = arr[3] * 1000
-- cleanup
arr = nil
if (state == "false") then -- если state = false (открыли дверь)
  if (zigbee.value(deviceAddr, deviceState) == "OFF") then -- если выключатель выключен
    	zigbee.set(deviceAddr, deviceState, "ON") -- то включить
  end
  -- запускаю таймер
  local startTime = os.time() -- записываю текущее время запуска таймера в локальную переменную
  obj.set("timerTambur", startTime) -- записываю текущее время запуска таймера в суперглобальную переменную
  os.delay(timer)
  -- по окончании таймера выключить реле, если таймер не был запущен в соседнем процессе
  -- для этого сравниваю локальную переменную с суперглобальной
  -- если они равны, значит таймер запущен в текущем процессе скрипта и можно гасить свет
  -- если не равны, значит таймер запущен в соседнем процессе и свет погасит он
  if (obj.getTime("timerTambur") == startTime) then
    zigbee.set(deviceAddr, deviceState, "OFF")
  end
end
