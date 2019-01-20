#!/usr/local/bin/ruby

require 'net/http'
require 'uri'
require 'json'

# download the list
uri = URI.parse("https://api.airtable.com/v0/#{ENV.fetch("AIRTABLE_ACC")}/#{ENV.fetch("AIRTABLE_TABLE")}")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer #{ENV.fetch("AIRTABLE_KEY")}"

req_options = { use_ssl: uri.scheme == "https" }
response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http| http.request(request) }

if response.code != "200"
  fail response.body
end

data = JSON.parse(response.body)

if data["records"].length == 100
  fail "We need to start paging results"
end

# find the current min
selected = data["records"].shuffle.sort_by { |r| r["fields"]["count"] }.first

# notify
uri = URI.parse("https://api.pushover.net/1/messages.json")
request = Net::HTTP::Post.new(uri)
request.set_form_data(
  "token" => ENV.fetch("PUSHOVER_TOKEN"),
  "user" => ENV.fetch("PUSHOVER_USER"),
  "message" => selected["fields"]["url"],
)

response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http| http.request(request) }

if response.code != "200"
  fail response.body
end

# update the count for next time
uri = URI.parse("https://api.airtable.com/v0/#{ENV.fetch("AIRTABLE_ACC")}/#{ENV.fetch("AIRTABLE_TABLE")}/#{selected["id"]}")
request = Net::HTTP::Patch.new(uri)
request.content_type = "application/json"
request["Authorization"] = "Bearer #{ENV.fetch("AIRTABLE_KEY")}"
request.body = JSON.dump({
  "fields" => {
    "count" => selected["fields"]["count"] + 1
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |http| http.request(request) }

if response.code != "200"
  fail response.body
end
