# TimestampRequestMiddleware = Struct.new(:app) do
#   def call(env)
#     env.url.query = REST.add_query_param(
#       env.url.query, 'timestamp', DateTime.now.strftime('%Q')
#     )
#
#     app.call env
#   end
# end
#
# SignRequestMiddleware = Struct.new(:app, :secret_key) do
#   def call(env)
#     value = OpenSSL::HMAC.hexdigest(
#       OpenSSL::Digest.new('sha256'), secret_key, env.url.query
#     )
#     env.url.query = REST.add_query_param(env.url.query, 'signature', value)
#
#     app.call env
#   end
# end
#
# BASE_URL = 'https://bb.otcbtc.com'.freeze
#
# conn=Faraday.new(url: "#{BASE_URL}/") do |conn|
#   conn.request :url_encoded
#   conn.response :json, content_type: /\bjson$/
#   conn.headers['X-MBX-APIKEY'] = base.api_key
#   conn.use TimestampRequestMiddleware
#   conn.use SignRequestMiddleware, base.secret_key
#   conn.adapter base.adapter
# end
#
# response = conn.send do |req|
#   req.url "/api/v2/users/me"
#   req.params.merge! options
# end
#
# response.body

BASE_URL = 'https://bb.otcbtc.com'.freeze

@access_key="tCGIgcRSbOAR3ErqCaSGeMLMrKUrS1O1E0u1xtfM"
@secret_key="LwdT8***************************"

payload="GET|/api/v2/users/me|access_key=#{@access_key}"

@signature=OpenSSL::HMAC.hexdigest(
  OpenSSL::Digest.new('sha256'),payload, @secret_key
)
puts "====#{@signature}"

# response=RestClient.get("#{BASE_URL}/api/v2/users/me",{access_key: @access_key,signature: @signature})
response=RestClient.get("#{BASE_URL}/api/v2/users/me?access_key=#{@access_key}&signature=#{@signature}")

response.body