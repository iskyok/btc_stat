url="http://api.lb.mytoken.org/currency/list"
params={
  "change_type":"change_utc0",
  "code":"69eb62dff694d6e18987a7e383d0bf86",
  "udid":"1666a73aac8095e2a831486ca57d6a044b7d96c2",
  "mytoken":"4455e9adf8528264211bc7e7e3d26ac1",
  "timestamp": Time.now.to_i,
  "device_model":"iPhone8,2",
  "device_os":"iOS11.2.6",
  "direction":"desc",
  "group_type":"2",
  "id":"1",
  "language":"zh_CN",
  "legal_currency":"CNY",
  "platform":"ios",
  "sort":"market_cap_usd",
  "type":"2",
  "page":"2",
  "size":"20",
  "v":"1.6.0"}

# response=RestClient.get(url,params)
url=url+"?#{params.to_param}"
puts "9999999---#{url}"
response=RestClient.post(url,params)

puts "=====#{response}"